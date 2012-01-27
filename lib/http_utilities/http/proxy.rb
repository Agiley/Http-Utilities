require 'open-uri'
require 'uri'

module HttpUtilities
  module Http
    module Proxy

      def set_proxy_options(proxy_options = {})
        self.proxy                =   {}

        options                   =   (proxy_options.is_a?(Hash)) ? proxy_options.clone() : {}

        use_proxy                 =   options.delete(:use_proxy) { |e| false }
        proxy                     =   options.delete(:proxy) { |e| nil }
        proxy_username            =   options.delete(:proxy_username) { |e| nil }
        proxy_password            =   options.delete(:proxy_password) { |e| nil }
        proxy_credentials         =   options.delete(:proxy_credentials) { |e| nil }
        reset_proxy               =   options.delete(:reset_proxy) { |e| true }

        if (reset_proxy)
          self.proxy              =   {}
          self.proxy[:host]       =   options.delete(:proxy_host) { |e| nil }
          self.proxy[:port]       =   options.delete(:proxy_port) { |e| nil }
          self.proxy[:protocol]   =   options.delete(:proxy_protocol) { |e| :http }
          self.proxy[:type]       =   options.delete(:proxy_type) { |e| :all }
        end

        if ((use_proxy || (proxy && !self.using_proxy?)
          if (proxy && proxy.is_a?(String))
            proxy = proxy.gsub(/^http(s)?:\/\//i, "")
            parts = proxy.split(":")

            if (parts.size.eql?(2))
              self.proxy[:host] = parts.first
              self.proxy[:port] = parts.second.to_i
            end

          elsif (proxy && proxy.is_a?(Hash) && !proxy.empty?)
            self.proxy          = proxy

          else
            proxy_object = ::Proxy.get_random_proxy(self.proxy[:protocol], self.proxy[:type])

            if (proxy_object)
              self.proxy[:host] = proxy_object.host
              self.proxy[:port] = proxy_object.port
            end
          end
        end

        set_proxy_credentials(proxy_username, proxy_password, proxy_credentials)
      end

      def set_proxy_credentials(proxy_username, proxy_password, proxy_credentials)
        if (self.using_proxy? && (!self.proxy[:username] || !self.proxy[:password]))
          if (proxy_username && proxy_password)
            self.proxy[:username] = proxy_username
            self.proxy[:password] = proxy_password

          elsif (proxy_credentials)
            if (proxy_credentials.is_a?(Hash))
              self.proxy[:username] = proxy_credentials[:username]
              self.proxy[:password] = proxy_credentials[:password]

            elsif (proxy_credentials.is_a?(String))
              parts = proxy_credentials.split(":")

              if (parts && parts.any? && parts.size >= 2)
                self.proxy[:username] = parts.first
                self.proxy[:password] = parts.second
              end

            end
          end
        end
      end
      
      def using_proxy?
        return (self.proxy[:host] && self.proxy[:port] && self.proxy[:port] > 0)
      end

    end
  end
end

