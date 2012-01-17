require 'open-uri'
require 'net/http'
require 'uri'

module HttpUtilities
  module Http
    module NetHttp

      def post_and_retrieve_content_using_net_http(url, data, options = {})
        uri         =   URI.parse(url) rescue nil
        net_http    =   set_net_http_options(uri, options)
        http        =   net_http[:http]
        proxy       =   net_http[:proxy]
        response    =   nil

        opts = options.clone()
        content_type = opts.delete(:content_type) { |e| nil }

        if (http && data)
          data = (data.is_a?(Hash)) ? generate_request_params(data) : data

          http.start do |http|
            headers = {}
            headers["User-Agent"]     =   randomize_user_agent_string
            headers["Content-Type"]   =   content_type if (content_type && content_type.present?)

            http.post(uri.request_uri, data, headers) do |response_data|
              response  =   response_data
            end

            response    =   convert_with_iconv(response) if (force_encoding)
          end
        end

        return response
      end

      def set_net_http_options(uri, options = {})
        proxy = set_proxy_options(options)
        http  = Net::HTTP.new(uri.host, uri.port, proxy[:host], proxy[:port]) rescue nil
        return {:http => http, :proxy => proxy}
      end

      def retrieve_net_http_content(url, options = {})
        uri = URI.parse(url) rescue nil

        net_http    =   set_net_http_options(uri, options)
        http        =   net_http[:http]
        proxy       =   net_http[:proxy]

        return perform_net_http_request(http, uri, options, proxy)
      end

      def perform_net_http_request(http_or_url, uri = nil, options = {}, proxy = nil, cookies = nil, redirect_count = 0, max_redirects = 3)
        response = nil
        retries, max_retries = 0, 3

        if (http_or_url)
          opts              =   (options.is_a?(Hash)) ? options.clone() : {} #Multi-threading woes...
          force_encoding    =   opts.delete(:force_encoding) { |e| false }
          use_cookies       =   opts.delete(:use_cookies) { |e| false }
          save_cookies      =   opts.delete(:save_cookies) { |e| true}
          request_cookies   =   opts.delete(:cookies) { |e| nil }
          timeout           =   opts.delete(:timeout) { |e| 60 }

          if (http_or_url.is_a?(String))
            uri       =   URI.parse(http_or_url) rescue nil
            net_http  =   self.set_net_http_options(uri, options)
            http      =   net_http[:http]
            proxy     =   net_http[:proxy]
          else
            http      =   http_or_url
          end

          if (uri && uri.request_uri)
            request_uri       =   uri.request_uri
            request           =   Net::HTTP::Get.new(request_uri, headers)
            headers           =   {"User-Agent" => self.randomize_user_agent_string}
            headers, cookies  =   set_cookies(headers, cookies, use_cookies, request_cookies, save_cookies)
          end

          begin
            http.start do |http|
              http.read_timeout   =   timeout
              response = http.request(request)
            end

          rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::ENETUNREACH, Errno::ECONNRESET, Timeout::Error, Net::HTTPUnauthorized, Net::HTTPForbidden => error
            retries += 1
            retry if (retries < max_retries)
          end
        end

        if (response)
          location = response['location']

          if (!(response.code =~ /^30\d{1}/i).nil? && location && location.present? && !location.eql?("/"))
            redirect_count +=   1
            cookies         =   handle_cookies(use_cookies, save_cookies, response)

            if (redirect_count < max_redirects)
              puts "\nRedirecting to location: #{response['location']}\n"
              result    =  perform_net_http_request(location, uri, options, proxy, cookies, redirect_count, max_redirects)

              response  =  result[:response]
              proxy     =  result[:proxy]
              cookies   =  result[:cookies]
            end
          end

          cookies     =   handle_cookies(use_cookies, save_cookies, response)
          response    =   (response.is_a?(String)) ? response : response.body rescue nil
          response    =   convert_with_iconv(response) if (force_encoding)
        end

        return {:response => response, :proxy => proxy, :cookies => cookies}
      end

    end
  end
end

