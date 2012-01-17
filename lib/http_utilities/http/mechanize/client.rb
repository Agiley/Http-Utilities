# -*- encoding : utf-8 -*-
require 'open-uri'
require 'net/http'
require 'uri'
require 'cgi'
require 'iconv'
require 'mechanize'

module HttpUtilities
  module Http
    module Mechanize

      class Client
        include HttpUtilities::Http::Proxy
        include HttpUtilities::Http::UserAgent
        include HttpUtilities::Http::Url
        include HttpUtilities::Http::Logger

        attr_accessor :user_agents

        def initialize
          self.set_user_agents
        end

        def init_request(options = {})
          request   =   HttpUtilities::Http::Request.new(::Mechanize.new)
          request.set_proxy_options(options)
          request.interface.set_proxy(request.proxy[:host], request.proxy[:port], request.proxy[:username], request.proxy[:password]) if (request.proxy[:host] && request.proxy[:port])

          user_agent = randomize_user_agent_string
          (user_agent) ? request.interface.user_agent = user_agent : request.interface.user_agent_alias = 'Mac Safari'

          timeout = options.delete(:timeout) { |e| 300 }
          request.interface.open_timeout = request.interface.read_timeout = timeout if (timeout)

          return request
        end

        def set_form_and_submit(url_or_page, form_identifier = {}, submit_identifier = :first, fields = {}, client_options = {}, retries = 0, max_retries = 3)
          options         =   client_options.clone()
          response_only   =   options.delete(:response_only) { |e| true }

          request = init_request(options)
          page, response_page, form = nil, nil, nil

          if (url_or_page.is_a?(String))
            response  =   open_url(request, url_or_page, options)
            page      =   response.page_object
          else
            page      =   url_or_page
          end

          if (page && page.is_a?(::Mechanize::Page)) #Occasionally proxies will yield Mechanize::File instead of a proper page
            if (form_identifier.has_key?(:array) && form_identifier.has_key?(:index))
              form = page.forms[form_identifier[:index]]
            else
              form = page.form_with(form_identifier)
            end

            if (form)
              form    =   reset_radiobuttons(form)
              form    =   set_form_fields(form, fields)
              button  =   (submit_identifier.nil? || submit_identifier.eql?(:first)) ? form.buttons.first : form.button_with(submit_identifier)

              begin
                response_page = request.interface.submit(form, button)
              rescue Exception => e
                log(:error, "[HttpUtilities::Http::Mechanize::Client] - Failed to submit form. Error: #{e.class.name} - #{e.message}.")
              end

            else
              log(:info, "[HttpUtilities::Http::Mechanize::Client] - Couldn't find form with identifier #{form_identifier.inspect}")
            end

          elsif ((!page || !page.is_a?(::Mechanize::Page)) && retries < max_retries)
            log(:info, "[HttpUtilities::Http::Mechanize::Client] - Couldn't find page or it wasn't a page.")
            retries += 1
            set_form_and_submit(url_or_page, form_identifier, submit_identifier, fields, options, retries, max_retries)
          end
          
          response              =   HttpUtilities::Http::Response.new
          response.page_object  =   response_page
          response.request      =   request

          return response
        end

        def open_url(request, url, client_options = {}, open_retries = 0, max_open_retries = 5)
          options = client_options.clone()

          page = nil

          begin
            page = request.interface.get(url)

          rescue Net::HTTPNotFound, ::Mechanize::ResponseCodeError => error
            log(:error, "[HttpUtilities::Http::Mechanize::Client] - 404 occurred for url #{url}. Error message: #{error.message}")

          rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT, Errno::ECONNRESET, Timeout::Error, Net::HTTPUnauthorized, Net::HTTPForbidden => connection_error
            log(:error, "[HttpUtilities::Http::Mechanize::Client] - Error occurred. Error class: #{connection_error.class.name}. Message: #{connection_error.message}")

            if (open_retries < max_open_retries)
              open_retries += 1

              request = init_request(options)
              retry
            end

          rescue StandardError => error
            log(:error, "[HttpUtilities::Http::Mechanize::Client] - Error occurred. Error class: #{error.class.name}. Message: #{error.message}")

            if (open_retries < max_open_retries)
              open_retries += 1

              request = init_request(options)
              retry
            end
          end
        
          response              =   HttpUtilities::Http::Response.new
          response.page_object  =   page
          response.request      =   request

          return response
        end

        def reset_radiobuttons(form)
          form.radiobuttons.each do |radiobutton|
            radiobutton.checked = false
          end if (form && form.radiobuttons && form.radiobuttons.any?)

          return form
        end

        def set_form_fields(form, fields)
          if (form && fields && !fields.empty?)
            fields.each do |key, value|
              form = set_form_field(form, key, value)
            end
          end

          return form
        end

        def set_form_field(form, key, value)
          if (value[:type].eql?(:input))
            log(:info, "[HttpUtilities::Http::Mechanize::Client] - Setting form field #{key} to value #{value[:value]}.")
            form.has_field?(key.to_s) ? form.field_with(:name => key.to_s).value = value[:value].to_s : set_form_fields(form, value[:fallbacks])
          elsif (value[:type].eql?(:checkbox))
            log(:info, "[HttpUtilities::Http::Mechanize::Client] - Setting #{key} to checked: #{value[:checked]}.")
            status = form.checkbox_with(:name => key.to_s).checked = value[:checked]
          elsif (value[:type].eql?(:radiobutton))
            log(:info, "[HttpUtilities::Http::Mechanize::Client] - Setting #{key} to checked: #{value[:checked]}.")
            status = form.radiobutton_with(:name => key.to_s).checked = value[:checked]
          elsif (value[:type].eql?(:file_upload))
            log(:info, "[HttpUtilities::Http::Mechanize::Client] - Setting file upload #{key} to value #{value[:value]}.")
            status = form.file_upload_with(:name => key.to_s).file_name = value[:value].to_s
          end

          return form
        end

        def get_parser(page)
          parser = nil

          if (page.is_a?(::Mechanize::Page))
            parser = page.parser
          elsif (page.is_a?(::Mechanize::File))
            parser = Nokogiri::HTML(page.body, nil, "utf-8")
          end

          return parser
        end

      end

    end
  end
end

