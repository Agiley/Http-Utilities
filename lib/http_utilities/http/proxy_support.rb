require 'open-uri'
require 'uri'

module HttpUtilities
  module Http
    module ProxySupport

      def set_proxy_options(options = {})
        use_proxy                 =   options.fetch(:use_proxy, false)
        specific_proxy            =   options.fetch(:proxy, nil)
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
        
        if (use_proxy || (specific_proxy && !self.using_proxy?))
          if (specific_proxy && specific_proxy.is_a?(String))
            specific_proxy        =   specific_proxy.gsub(/^http(s)?:\/\//i, "")
            parts                 =   specific_proxy.split(":")

            if (parts.size.eql?(2))
              self.proxy[:host]   =   parts.first
              self.proxy[:port]   =   parts.second.to_i
            end

          elsif (specific_proxy && specific_proxy.is_a?(Hash) && !specific_proxy.empty? && specific_proxy[:host] && specific_proxy[:port])
            self.proxy            =   specific_proxy

          elsif (proxy_model_defined?)
            proxy_object = Proxy.get_random_proxy(self.proxy[:protocol], self.proxy[:type])
            
            #log(:info, "[HttpUtilities::Http::ProxySupport] - Randomized Proxy object: #{proxy_object.inspect}")

            if (proxy_object)
              self.proxy[:host]   =   proxy_object.host
              self.proxy[:port]   =   proxy_object.port
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
      
      def proxy_model_defined?
        defined = Module.const_get("Proxy").is_a?(Class) rescue false
        defined = (defined && Proxy.respond_to?(:get_random_proxy))
        
        return defined
      end
      
      def using_proxy?
        return (self.proxy[:host] && self.proxy[:port] && self.proxy[:port] > 0)
      end

    end
  end
end