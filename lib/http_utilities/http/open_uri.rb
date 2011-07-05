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

        self.set_proxy_options(options)

        if (self.proxy[:host] && self.proxy[:port])
          proxy_address = Proxy.format_proxy_address(self.proxy[:host], self.proxy[:port], true)
          open_uri_options[:proxy] = proxy_address

          if (self.proxy[:username] && self.proxy[:password])
            open_uri_options[:proxy_http_basic_authentication] = [proxy_address, self.proxy[:username], self.proxy[:password]]
          end
        end

        connection = nil
        while (connection.nil? && retries < max_retries)
          connection = open(url, open_uri_options) rescue nil
          retries += 1
        end

        if (connection)
          connection.rewind
          ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
          response = ic.iconv(connection.readlines.join("\n") + ' ')[0..-2] rescue nil
          response = response.force_encoding('UTF-8') if (response)
        end

        return response
      end
      
    end
  end
end