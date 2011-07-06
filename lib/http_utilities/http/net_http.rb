require 'open-uri'
require 'net/http'
require 'uri'

module HttpUtilities
  module Http
    module NetHttp
      
      def post_and_retrieve_content_using_net_http(url, data, options = {})
        uri = URI.parse(url) rescue nil
        http = set_net_http_options(uri, options)
        response = nil
        
        opts = options.clone()
        content_type = opts.delete(:content_type) { |e| nil }

        if (http && data)
          data = (data.is_a?(Hash)) ? generate_request_params(data) : data

          http.start do |http|
            headers = {}
            headers["User-Agent"] = randomize_user_agent_string
            headers["Content-Type"] = content_type if (content_type && content_type.present?)
            
            http.post(uri.request_uri, data, headers) do |response_data|
              response = response_data
            end
            
            if (response && response.present?)
              ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
              response = ic.iconv(response + ' ')[0..-2] rescue nil
              response = response.force_encoding('utf-8') rescue nil
            end
          end
        end

        return response
      end
      
      def set_net_http_options(uri, options = {})
        self.set_proxy_options(options)
        return Net::HTTP.new(uri.host, uri.port, self.proxy[:host], self.proxy[:port]) rescue nil
      end

      def retrieve_net_http_content(url, options = {})
        uri = URI.parse(url) rescue nil
        http = set_net_http_options(uri, options)

        return perform_net_http_request(http, uri, options)
      end

      def perform_net_http_request(http_or_url, uri = nil, options = {}, redirect_count = 0, max_redirects = 3)
        response = nil

        if (http_or_url)
          if (http_or_url.is_a?(String))
            uri = URI.parse(http_or_url) rescue nil
            http = set_net_http_options(uri, options)
          else
            http = http_or_url
          end

          begin
            opts              =   (options.is_a?(Hash)) ? options.clone() : {} #Multi-threading woes...
            force_encoding    =   opts.delete(:force_encoding) { |e| false }
            use_cookies       =   opts.delete(:use_cookies) { |e| false }
            save_cookies      =   opts.delete(:save_cookies) { |e| true}
            request_cookies   =   opts.delete(:cookies) { |e| nil }

            http.start do |http|
              request_uri = uri.request_uri rescue nil

              if (request_uri)              
                headers = {"User-Agent" => randomize_user_agent_string}

                if ((use_cookies && self.cookies) || request_cookies)
                  self.cookies = (request_cookies) ? request_cookies : self.cookies
                  cookie_string = (self.cookies.is_a?(Array)) ? format_cookies(self.cookies) : self.cookies
                  headers.merge!({'cookie' => cookie_string}) 
                elsif (!use_cookies)
                  self.mutex.synchronize do
                    self.cookies = nil
                  end
                end

                #puts "NET HTTP HEADERS: #{headers.inspect}\n\n"

                request = Net::HTTP::Get.new(request_uri, headers)
                response = http.request(request) rescue nil

                if (response)
                  if (!(response.code =~ /^30\d{1}/i).nil? && response['location'] && response['location'].present?)
                    redirect_count += 1
                    handle_cookies(use_cookies, save_cookies, response)
                    puts "\nRedirecting to location: #{response['location']}\n"
                    response = perform_net_http_request(response['location'], uri, options, redirect_count, max_redirects) if (redirect_count < max_redirects)
                  end

                  handle_cookies(use_cookies, save_cookies, response)

                  response = (response.is_a?(String)) ? response : response.body
                  #puts "Response body: #{response}"

                  if (force_encoding)
                    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
                    response = ic.iconv(response + ' ')[0..-2] rescue nil
                    response = response.force_encoding('utf-8') rescue nil
                  end

                end
              end
            end
          rescue
            puts "Exception occurred while trying to connect."
          end
        end

        return response
      end
      
    end
  end
end