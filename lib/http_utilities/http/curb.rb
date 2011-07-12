require 'uri'

module HttpUtilities
  module Http
    module Curb
      
      def post_and_retrieve_content_using_curl(url, data, options = {})
        curl = set_curl_options(url, options)
        response = nil

        if (curl && data)

          if (data.is_a?(Hash))
            data = data.map { |key, value| Curl::PostField.content(key.to_s, value.to_s) }
          end

          curl.http_post(data) rescue nil
          response = curl.body_str rescue nil
        end

        return response
      end
      
      def retrieve_parsed_xml_concurrently(urls, options = {})
        return retrieve_parsed_content_concurrently(urls, options, :xml) 
      end

      def retrieve_parsed_html_concurrently(urls, options = {})
        return retrieve_parsed_content_concurrently(urls, options, :html) 
      end

      def retrieve_parsed_content_concurrently(urls, options = {}, format = :xml)
        urls = [*urls]
        concurrent_requests = options.delete(:concurrent_requests) { |e| 2 }

        multi = Curl::Multi.new
        responses = []

        urls.slice!(0, concurrent_requests).each do |url|
          self.add_url_to_multi(multi, url, urls, responses, options, format)
        end

        multi.perform

        return responses
      end

      def add_url_to_multi(multi, url, url_queue, responses = [], options = {}, format = :xml)
        curl = self.set_curl_options(url, options)

        curl.on_success do |data|
          self.add_url_to_multi(multi, url_queue.shift, url_queue, responses, options) if (url_queue.any?)
          if (data.body_str && data.body_str.present?)
            responses << format.eql?(:xml) ? as_xml(data.body_str) : as_html(data.body_str) 
          end
        end

        curl.on_failure do |data, error|
          add_url_to_multi(multi, url_queue.shift, url_queue, responses, options) if (url_queue.any?)
        end

        multi.add(curl) rescue false
      end
      
      def retrieve_curl_content(url, options = {})
        curl = self.set_curl_options(url, options)

        begin
          success = curl.perform
          response = curl.body_str

          if (response && response.present?)
            ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
            response = ic.iconv(response + ' ')[0..-2] rescue nil
            response = response.force_encoding('utf-8') rescue nil
          end

        rescue Exception => e
          puts "\n\n#{Time.now}: IMPORTANT! Error occurred while trying to retrieve content from url #{url} and parse it. Error: #{e.message}. Error Class: #{e.class}"
          response = ""
        end
      end

      def go_to_url(url, options = {})
        success = false
        curl = self.set_curl_options(url, options)
        success = curl.perform rescue false      
        success = (success && curl.response_code.eql?(200))
        return success
      end

      def set_curl_options(url, options = {})
        options               =   options.clone()

        self.set_proxy_options(options)

        accept_cookies        =   options.delete(:accept_cookies) { |e| false }
        timeout               =   options.delete(:timeout) { |e| 120 }
        maximum_redirects     =   options.delete(:maximum_redirects) { |e| 10 }
        disable_auth          =   options.delete(:disable_auth) { |e| false }
        accept_content_type   =   options.delete(:accept_content_type) { |e| false }
        content_type          =   options.delete(:content_type) { |e| false }
        cookie_file           =   nil

        curl = Curl::Easy.new(url) do |c| 
          c.headers ||= {}
          c.headers["User-Agent"]     =   c.useragent = randomize_user_agent_string
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

          curl.enable_cookies = true
          curl.cookiejar = cookie_file
          curl.cookiefile = cookie_file
        end

        if (self.proxy[:host] && self.proxy[:port])
          curl.proxy_url    =   ::Proxy.format_proxy_address(self.proxy[:host], self.proxy[:port], false)
          curl.proxy_type   =   5 if (self.proxy[:protocol] && self.proxy[:protocol].present? && self.proxy[:protocol].downcase.eql?('socks5'))
          curl.proxypwd     =   ::Proxy.format_proxy_credentials(self.proxy[:username], self.proxy[:password]) if (self.proxy[:username] && self.proxy[:password])
        end

        return curl
      end
      
    end
  end
end