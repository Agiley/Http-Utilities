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
              headers["Content-Type"]   =   content_type if (content_type && content_type.present?)

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
          cookies   =   nil
          retries, max_retries = 0, 3

          if (request_or_url)
            opts              =   (options.is_a?(Hash)) ? options.clone() : {} #Multi-threading woes...
            force_encoding    =   opts.delete(:force_encoding) { |e| false }
            request_cookies   =   opts.delete(:cookies) { |e| nil }
            timeout           =   opts.delete(:timeout) { |e| 60 }

            if (request_or_url.is_a?(String))
              uri       =   URI.parse(request_or_url)
              request   =   self.set_net_http_options(uri, options)
            else
              request   =   request_or_url
            end

            if (uri && uri.request_uri)
              headers           =   {"User-Agent" => request.user_agent}
              headers, cookies  =   set_cookies(headers, cookies, request_cookies)
              
              request_uri       =   uri.request_uri
              http_request      =   Net::HTTP::Get.new(request_uri, headers)
            end

            begin
              request.interface.start do |http|
                http.read_timeout   =   timeout
                response = http.request(http_request)
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
              request.cookies = handle_cookies(response)

              if (redirect_count < max_redirects)
                log(:info, "[HttpUtilities::Http::Client] - Redirecting to location: #{response['location']}.")
                response      =  perform_net_http_request(location, uri, options, redirect_count, max_redirects)
              end
            end

            request.cookies   =   handle_cookies(response)
            response          =   (response.is_a?(String)) ? response : response.body rescue nil
            response          =   HttpUtilities::Http::Response.new(response, request, options)
          end

          return response
        end

      end
    end
  end
end