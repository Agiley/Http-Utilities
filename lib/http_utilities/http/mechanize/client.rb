# -*- encoding : utf-8 -*-
require 'open-uri'
require 'net/http'
require 'uri'
require 'cgi'
require 'mechanize'

module HttpUtilities
  module Http
    module Mechanize

      class Client
        attr_accessor :agent, :proxy, :user_agent
        
        include HttpUtilities::Http::Proxy
        include HttpUtilities::Http::Url
        include HttpUtilities::Http::Logger
        include HttpUtilities::Http::UserAgent
        
        def initialize(options = {})
          init_agent(options)
        end
        
        def init_agent(options = {})
          self.agent = ::Mechanize.new
          
          self.set_proxy_options(options)
          self.agent.set_proxy(self.proxy[:host], self.proxy[:port], self.proxy[:username], self.proxy[:password]) if (self.proxy[:host] && self.proxy[:port])
          
          self.set_user_agent
          (self.user_agent) ? self.agent.user_agent = self.user_agent : self.agent.user_agent_alias = 'Mac Safari'
          
          timeout                   =   options.fetch(:timeout, 300)
          self.agent.open_timeout   =   self.agent.read_timeout = timeout if (timeout)
        end
        
        def reset_agent(options = {})
          self.agent, self.proxy, self.user_agent = nil
          init_agent(options)
        end
        
        def open_url(url, options = {}, retries = 3)
          page = nil

          begin
            page = self.agent.get(url)

          rescue Net::HTTPNotFound, ::Mechanize::ResponseCodeError => error
            log(:error, "[HttpUtilities::Http::Mechanize::Client] - Response Code Error occurred for url #{url}. Error class: #{error.class.name}. Error message: #{error.message}")
            
            if (retries > 0)
              reset_agent(options)
              retries -= 1
              
              retry
            end
            
          rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT, Errno::ECONNRESET, Timeout::Error, Net::HTTPUnauthorized, Net::HTTPForbidden, StandardError => connection_error
            log(:error, "[HttpUtilities::Http::Mechanize::Client] - Error occurred. Error class: #{connection_error.class.name}. Message: #{connection_error.message}")

            if (retries > 0)
              reset_agent
              retries -= 1
              
              retry
            end
          end

          return page
        end

        def set_form_and_submit(url_or_page, form_identifier = {}, submit_identifier = :first, fields = {}, options = {}, retries = 3)
          should_reset_radio_buttons  =   options.fetch(:should_reset_radio_buttons, false)
          page, response_page, form   =   nil, nil, nil

          if (url_or_page.is_a?(String))
            page        =   open_url(url_or_page, options)
          else
            page        =   url_or_page
          end

          if (page && page.is_a?(::Mechanize::Page)) #Occasionally proxies will yield Mechanize::File instead of a proper page
            if (form_identifier.has_key?(:array) && form_identifier.has_key?(:index))
              form = page.forms[form_identifier[:index]]
            else
              form = page.form_with(form_identifier)
            end

            if (form)
              form.action     =     "#{url_or_page}#{form.action}"  if (url_or_page.is_a?(String) && form.action.starts_with?("#"))
              form            =     reset_radio_buttons(form)       if (should_reset_radio_buttons)
              form            =     set_form_fields(form, fields)
              button          =     (submit_identifier.nil? || submit_identifier.eql?(:first)) ? form.buttons.first : form.button_with(submit_identifier)

              begin
                response_page = self.agent.submit(form, button)
              rescue Exception => e
                log(:error, "[HttpUtilities::Http::Mechanize::Client] - Failed to submit form. Error: #{e.class.name} - #{e.message}.")
              end

            else
              log(:info, "[HttpUtilities::Http::Mechanize::Client] - Couldn't find form with identifier #{form_identifier.inspect}")
            end

          elsif ((!page || !page.is_a?(::Mechanize::Page)) && retries > 0)
            log(:info, "[HttpUtilities::Http::Mechanize::Client] - Couldn't find page or it wasn't a page.")
            retries -= 1
            reset_agent
            set_form_and_submit(url_or_page, form_identifier, submit_identifier, fields, options, retries)
          end

          return response_page
        end

        def reset_radio_buttons(form)
          radio_buttons = form.radiobuttons
          
          radio_buttons.each do |radio_button|
            radio_button.checked = false
          end if (form && radio_buttons && radio_buttons.any?)

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

