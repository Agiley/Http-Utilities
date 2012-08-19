require 'open-uri'
require 'net/http'
require 'uri'

module HttpUtilities
  module Http
    module Adapters
      module NetHttp

        def post_and_retrieve_content_using_net_http(url, data, options = {})
          uri             =   URI.parse(url) rescue nil
          request         =   set_net_http_options(uri, options)
          response        =   nil

          opts            =   options.clone()
          content_type    =   opts.delete(:content_type) { |e| nil }

          if (request.interface && data)
            data = (data.is_a?(Hash)) ? generate_request_params(data) : data

            request.interface.start do |http|
              headers = {}
              headers["User-Agent"]     =   request.user_agent
              headers["Content-Type"]   =   content_type if (content_type)

              http.post(uri.request_uri, data, headers) do |response_data|
                response  =   response_data
              end
              
              response    =   HttpUtilities::Http::Response.new(response, request, options)
            end
          end

          return response
        end

        def set_net_http_options(uri, options = {})
          request             =   HttpUtilities::Http::Request.new
          request.set_proxy_options(options)
          request.interface   =   Net::HTTP.new(uri.host, uri.port, request.proxy[:host], request.proxy[:port])

          return request
        end

        def retrieve_net_http_content(url, options = {})
          uri         =   URI.parse(url)
          request     =   set_net_http_options(uri, options)
          return perform_net_http_request(request, uri, options)
        end

        def perform_net_http_request(request_or_url, uri = nil, options = {}, redirect_count = 0, max_redirects = 5)
          request   =   nil
          response  =   nil

          if (request_or_url)
            opts              =   (options.is_a?(Hash)) ? options.clone() : {}
            retries           =   opts.delete(:retries) { |e| 3 }
            force_encoding    =   opts.delete(:force_encoding) { |e| false }
            cookies           =   opts.delete(:cookies) { |e| nil }
            timeout           =   opts.delete(:timeout) { |e| 30 }

            if (request_or_url.is_a?(String))
              uri       =   URI.parse(request_or_url)
              request   =   self.set_net_http_options(uri, options)
            else
              request   =   request_or_url
            end

            if (uri && uri.respond_to?(:request_uri) && uri.request_uri)
              headers           =   {"User-Agent" => request.user_agent}
              headers           =   set_cookies(headers, cookies)
              request_uri       =   uri.request_uri
              http_request      =   Net::HTTP::Get.new(request_uri, headers)
            end

            begin
              request.interface.start do |http|
                http.read_timeout   =   timeout
                response            =   http.request(http_request)
              end

            rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::ENETUNREACH, Errno::ECONNRESET, Timeout::Error, Net::HTTPUnauthorized, Net::HTTPForbidden => error
              log(:error, "[HttpUtilities::Http::Client] - Error occurred while trying to fetch url '#{uri.request_uri}'. Error Class: #{error.class.name}. Error Message: #{error.message}")
              retries -= 1
              retry if (retries > 0)
            end
          end

          if (response)
            location = response['location']

            if (!(response.code.to_s =~ /^30\d{1}/i).nil? && location && location.present?)
              location            =   location.strip.downcase
              redirect_count     +=   1
              
              if (redirect_count < max_redirects)
                request.cookies   =   handle_cookies(response)
                location          =   "http://#{uri.host}/#{location.gsub(/^\//i, "")}" if (uri && (location =~ /^http(s)?/i).nil?)
                
                log(:info, "[HttpUtilities::Http::Client] - Redirecting to location: #{location}.")
                
                options           =   options.merge(:cookies => request.cookies) if request.cookies
                response          =   perform_net_http_request(location, uri, options, redirect_count, max_redirects)
              end
            end

            request.cookies   =   handle_cookies(response)
            response          =   set_response(response)
            response          =   HttpUtilities::Http::Response.new(response, request, options)
          end

          return response
        end
        
        def set_response(response)
          if (response.is_a?(String))
            response = response
          elsif (response.is_a?(Net::HTTPResponse))
            response = response.body rescue nil
          elsif (response.is_a?(HttpUtilities::Http::Response))
            response = response.body
          end
          
          return response
        end

      end
    end
  end
end