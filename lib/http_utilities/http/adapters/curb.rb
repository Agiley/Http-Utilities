require 'uri'

module HttpUtilities
  module Http
    module Adapters
      module Curb

        def post_and_retrieve_content_using_curl(url, data, options = {})
          request   =   self.set_curl_options(url, options)
          response  =  nil

          if (request.interface && data)
            if (data.is_a?(Hash))
              data = data.map { |key, value| Curl::PostField.content(key.to_s, value.to_s) }
            end

            request.interface.http_post(data) rescue nil
            response = request.interface.body_str rescue nil
            response = HttpUtilities::Http::Response.new(response, request, options)
          end

          return response
        end

        def retrieve_curl_content(url, options = {})
          request     =   self.set_curl_options(url, options)
          response    =   nil

          begin
            success   =   request.interface.perform
            response  =   request.interface.body_str
            response  =   HttpUtilities::Http::Response.new(response, request, options)

          rescue Exception => e
            puts "\n\n#{Time.now}: IMPORTANT! Error occurred while trying to retrieve content from url #{url} and parse it. Error: #{e.message}. Error Class: #{e.class}"
          end

          return response
        end

        def go_to_url(url, options = {})
          success = false

          request = self.set_curl_options(url, options)

          success = request.interface.perform rescue false
          success = (success && curl.response_code.eql?(200))

          return success
        end

        def set_curl_options(url, options = {})
          options               =   options.clone()
          
          request               =   HttpUtilities::Http::Request.new
          request.set_proxy_options(options)

          accept_cookies        =   options.delete(:accept_cookies) { |e| false }
          timeout               =   options.delete(:timeout) { |e| 120 }
          maximum_redirects     =   options.delete(:maximum_redirects) { |e| 10 }
          disable_auth          =   options.delete(:disable_auth) { |e| false }
          accept_content_type   =   options.delete(:accept_content_type) { |e| false }
          content_type          =   options.delete(:content_type) { |e| false }
          cookie_file           =   nil

          curl = Curl::Easy.new(url) do |c|
            c.headers ||= {}
            c.headers["User-Agent"]     =   c.useragent = request.user_agent
            c.headers["Accept"]         =   accept_content_type if (accept_content_type)
            c.headers["Content-Type"]   =   content_type if (content_type)
            c.timeout                   =   timeout
            c.ssl_verify_host           =   false
            c.follow_location           =   true
            c.max_redirects             =   maximum_redirects

            if (disable_auth)
              c.http_auth_types   = nil
              c.proxy_auth_types  = nil
              c.unrestricted_auth = false
            end
          end

          if (accept_cookies)
            FileUtils.mkdir_p File.join(Rails.root, "tmp/cookies")
            identifier = Time.now.to_date.to_s(:db).gsub("-", "_").gsub("\s", "_").gsub(":", "_")
            cookie_file = File.join(Rails.root, "tmp/cookies", "cookies_#{identifier}.txt")

            curl.enable_cookies   =   true
            curl.cookiejar        =   cookie_file
            curl.cookiefile       =   cookie_file
          end

          if (request.proxy[:host] && request.proxy[:port])
            curl.proxy_url    =   ::Proxy.format_proxy_address(request.proxy[:host], request.proxy[:port], false)
            curl.proxy_type   =   5 if (request.proxy[:protocol] && request.proxy[:protocol].downcase.eql?('socks5'))
            curl.proxypwd     =   ::Proxy.format_proxy_credentials(request.proxy[:username], request.proxy[:password]) if (request.proxy[:username] && request.proxy[:password])
          end
          
          request.interface = curl

          return request
        end

      end
    end
  end
end