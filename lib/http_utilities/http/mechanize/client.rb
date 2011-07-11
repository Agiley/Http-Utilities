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
        include HttpUtilities::Http::Request
        include HttpUtilities::Http::Format

        attr_accessor :agent, :mutex, :user_agents, :proxy, :retries, :max_retries

        def initialize
          self.mutex          =   Mutex.new
          self.proxy          =   {}
          self.retries        =   0
          self.max_retries    =   5
          
          set_user_agents
          set_agent
        end
        
        def set_agent
          self.agent          =   nil
          self.agent          =   ::Mechanize.new
          #Sometimes Mechanize returns Mechanize::File instead of Mechanize::Page, force text/plain to be parsed as a Page
          self.agent.pluggable_parser['text/plain'] = ::Mechanize::Page
        end

        def get_parser(page)
          parser = nil

          if (page.is_a?(::Mechanize::Page))
            parser = page.parser
          elsif (page.is_a?(::Mechanize::File))
            parser = as_html(page.body)
          end

          return parser
        end

        def set_form_and_submit(url_or_page, form_identifier = {}, submit_identifier = :first, fields = {}, client_options = {})
          page, response_page, form = nil, nil, nil
          page = (url_or_page.is_a?(String)) ? open_url(url_or_page, client_options) : url_or_page

          if (page && page.is_a?(::Mechanize::Page)) #Occasionally proxies will yield Mechanize::File instead of a proper page

            if (form_identifier.has_key?(:array) && form_identifier.has_key?(:index))
              form = page.forms[form_identifier[:index]]
            else
              form = page.form_with(form_identifier)
            end

            if (form)
              form = reset_radiobuttons(form)
              form = set_form_fields(form, fields)
              button = (submit_identifier.nil? || submit_identifier.eql?(:first)) ? form.buttons.first : form.button_with(submit_identifier)
              response_page = self.agent.submit(form, button) rescue nil
            else
              Rails.logger.info "[HttpUtilities::Http::Mechanize::Client] - Couldn't find form with identifier #{form_identifier.inspect}"
            end

          elsif ((!page || !page.is_a?(::Mechanize::Page)) && self.retries < self.max_retries)
            Rails.logger.info "[HttpUtilities::Http::Mechanize::Client] - Couldn't find page or it wasn't a page."
            self.retries += 1
            set_agent
            set_form_and_submit(url_or_page, form_identifier, submit_identifier, fields, client_options)
          end

          return response_page
        end

        def open_url(url, client_options = {})
          options = client_options.clone()
          open_retries, max_open_retries = 0, 5
          page = nil
          
          set_agent_options(options)

          begin
            page = self.agent.get(url)

          rescue Net::HTTPNotFound, ::Mechanize::ResponseCodeError => error
            Rails.logger.error "[HttpUtilities::Http::Mechanize::Client] - 404 occurred for url #{url}. Error message: #{error.message}"

          rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT, Errno::ECONNRESET, Timeout::Error, Net::HTTPUnauthorized, Net::HTTPForbidden => connection_error
            Rails.logger.error "[HttpUtilities::Http::Mechanize::Client] - Error occurred. Error class: #{connection_error.class.name}. Message: #{connection_error.message}"

            open_retries += 1

            if (open_retries < max_open_retries)
              set_agent
              set_agent_options(options)
              retry
            end

          rescue StandardError => error
            Rails.logger.error "[HttpUtilities::Http::Mechanize::Client] - Error occurred. Error class: #{error.class.name}. Message: #{error.message}"

            open_retries += 1

            if (open_retries < max_open_retries)
              set_agent
              set_agent_options(options)
              retry
            end
          end

          return page
        end
        
        def set_agent_options(options)
          self.set_proxy_options(options)
          self.agent.set_proxy(self.proxy[:host], self.proxy[:port], self.proxy[:username], self.proxy[:password]) if (self.proxy[:host] && self.proxy[:port])
          
          user_agent = randomize_user_agent_string
          (user_agent) ? self.agent.user_agent = user_agent : self.agent.user_agent_alias = 'Mac Safari'
          
          timeout = options.delete(:timeout) { |e| 300 }
          
          if (timeout)
            self.agent.open_timeout = self.agent.read_timeout = timeout
          end
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
            #Rails.logger.info "[HttpUtilities::Http::Mechanize::Client] - Setting form field #{key} to value #{value[:value]}."
            form.has_field?(key.to_s) ? form.field_with(:name => key.to_s).value = value[:value].to_s : set_form_fields(form, value[:fallbacks])
          elsif (value[:type].eql?(:checkbox))
            #Rails.logger.info "[HttpUtilities::Http::Mechanize::Client] - Setting #{key} to checked: #{value[:checked]}."
            status = form.checkbox_with(:name => key.to_s).checked = value[:checked]
          elsif (value[:type].eql?(:radiobutton))
            #Rails.logger.info "[HttpUtilities::Http::Mechanize::Client] - Setting #{key} to checked: #{value[:checked]}."
            status = form.radiobutton_with(:name => key.to_s).checked = value[:checked]
          elsif (value[:type].eql?(:file_upload))
            #Rails.logger.info "[HttpUtilities::Http::Mechanize::Client] - Setting file upload #{key} to value #{value[:value]}."
            status = form.file_upload_with(:name => key.to_s).file_name = value[:value].to_s
          end

          return form
        end

      end
      
    end    
  end
end