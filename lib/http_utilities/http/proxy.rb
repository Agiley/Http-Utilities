require 'open-uri'
require 'uri'

module HttpUtilities
  module Http
    module Proxy

      def set_proxy_options(options = {})
        self.proxy                =   {}

        use_proxy                 =   options.fetch(:use_proxy, false)
        proxy                     =   options.fetch(:proxy, nil)
        proxy_username            =   options.fetch(:proxy_username, nil)
        proxy_password            =   options.fetch(:proxy_password, nil)
        proxy_credentials         =   options.fetch(:proxy_credentials, nil)
        reset_proxy               =   options.fetch(:reset_proxy, true)

        if (reset_proxy)
          self.proxy              =   {}
          self.proxy[:host]       =   options.fetch(:proxy_host, nil)
          self.proxy[:port]       =   options.fetch(:proxy_port, nil)
          self.proxy[:protocol]   =   options.fetch(:proxy_protocol, :http)
          self.proxy[:type]       =   options.fetch(:proxy_type, :all)
        end

        if (use_proxy || (proxy && !self.using_proxy?))
          if (proxy && proxy.is_a?(String))
            proxy = proxy.gsub(/^http(s)?:\/\//i, "")
            parts = proxy.split(":")

            if (parts.size.eql?(2))
              self.proxy[:host] = parts.first
              self.proxy[:port] = parts.second.to_i
            end

          elsif (proxy && proxy.is_a?(Hash) && !proxy.empty?)
            self.proxy          = proxy

          elsif (defined?(::Proxy))
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

