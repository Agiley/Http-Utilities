require 'open-uri'
require 'uri'

module HttpUtilities
  module Http
    module Adapters
      module OpenUri

        def retrieve_open_uri_content(url, options = {}, retries = 0, max_retries = 3)
          response  =   nil

          options   =   options.clone()
          request   =   HttpUtilities::Http::Request.new
          request.set_proxy_options(options)

          open_uri_options = {"UserAgent" => request.user_agent}
          open_uri_options[:read_timeout] = options.delete(:timeout) { |e| 120 }

          if (request.proxy[:host] && request.proxy[:port])
            proxy_address = Proxy.format_proxy_address(request.proxy[:host], request.proxy[:port], true)
            open_uri_options[:proxy] = proxy_address

            if (proxy[:username] && proxy[:password])
              open_uri_options[:proxy_http_basic_authentication] = [proxy_address, request.proxy[:username], request.proxy[:password]]
            end
          end

          connection = nil
          while (connection.nil? && retries < max_retries)
            connection = open(url, open_uri_options) rescue nil
            retries += 1
          end

          if (connection)
            connection.rewind
            response  =   connection.readlines.join("\n")
            response  =   HttpUtilities::Http::Response.new(response, request)
          end

          return response
        end

      end
    end
  end
end

