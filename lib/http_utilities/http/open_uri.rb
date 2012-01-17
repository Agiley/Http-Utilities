require 'open-uri'
require 'uri'

module HttpUtilities
  module Http
    module OpenUri

      def retrieve_open_uri_content(url, options = {}, retries = 0, max_retries = 3)
        response = nil

        options = options.clone()

        open_uri_options = {"UserAgent" => randomize_user_agent_string}
        open_uri_options[:read_timeout] = options.delete(:timeout) { |e| 120 }

        proxy = self.set_proxy_options(options)

        if (proxy[:host] && proxy[:port])
          proxy_address = Proxy.format_proxy_address(proxy[:host], proxy[:port], true)
          open_uri_options[:proxy] = proxy_address

          if (proxy[:username] && proxy[:password])
            open_uri_options[:proxy_http_basic_authentication] = [proxy_address, proxy[:username], proxy[:password]]
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
          response  =   convert_with_iconv(response)
        end

        return {:response => response, :proxy => proxy, :cookies => nil}
      end

    end
  end
end

