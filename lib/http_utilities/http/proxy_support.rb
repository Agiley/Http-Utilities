module HttpUtilities
  module Http
    module ProxySupport

      def set_proxy_options(options = {})
        use_proxy                 =   options.fetch(:use_proxy, false)
        specific_proxy            =   options.fetch(:proxy, nil)
        proxy_host                =   options.fetch(:proxy_host, nil)
        proxy_port                =   options.fetch(:proxy_port, nil)
        proxy_username            =   options.fetch(:proxy_username, nil)
        proxy_password            =   options.fetch(:proxy_password, nil)
        proxy_credentials         =   options.fetch(:proxy_credentials, nil)
        proxy_type                =   options.fetch(:proxy_type, :all)
        proxy_protocol            =   options.fetch(:proxy_protocol, :all)
        
        if use_proxy || specific_proxy
          self.proxy            ||=   {}
          
          if specific_proxy && specific_proxy.is_a?(String)
            specific_proxy        =   specific_proxy.gsub(/^http(s)?:\/\//i, "")
            parts                 =   specific_proxy.split(":")

            if parts.size.eql?(2)
              self.proxy[:host]   =   parts.first
              self.proxy[:port]   =   parts.second.to_i
            end

          elsif proxy_host && proxy_port
            self.proxy[:host]     =   proxy_host
            self.proxy[:port]     =   proxy_port

          elsif proxy_model_defined?
            if specific_proxy && specific_proxy.is_a?(::Proxy)
              proxy_object        =   specific_proxy
            else
              proxy_object        =   ::Proxy.get_random_proxy(protocol: proxy_protocol, proxy_type: proxy_type)
            end
            
            #log(:info, "[HttpUtilities::Http::ProxySupport] - Randomized Proxy object: #{proxy_object.inspect}")

            if proxy_object
              self.proxy[:host]   =   proxy_object.host
              self.proxy[:port]   =   proxy_object.port
              proxy_username      =   !proxy_object.username.to_s.empty? ? proxy_object.username : nil
              proxy_password      =   !proxy_object.password.to_s.empty? ? proxy_object.password : nil
            end
          end
          
          set_proxy_credentials(proxy_username, proxy_password, proxy_credentials)
        end
      end

      def set_proxy_credentials(proxy_username, proxy_password, proxy_credentials)
        if proxy_username && proxy_password
          self.proxy[:username]       =   proxy_username
          self.proxy[:password]       =   proxy_password

        elsif proxy_credentials
          if proxy_credentials.is_a?(Hash)
            self.proxy[:username]     =   proxy_credentials[:username]
            self.proxy[:password]     =   proxy_credentials[:password]

          elsif (proxy_credentials.is_a?(String))
            parts                     =   proxy_credentials.split(":")

            if parts && parts.any? && parts.size == 2
              self.proxy[:username]   =   parts.first
              self.proxy[:password]   =   parts.second
            end
          end
        end
      end
      
      def proxy_model_defined?
        defined                     =   Module.const_get("Proxy").is_a?(Class) rescue false
        defined                     =   (defined && ::Proxy.respond_to?(:get_random_proxy))
        
        return defined
      end
      
      def generate_proxy_options
        proxy_options               =   {}
        
        if self.proxy && !self.proxy[:host].to_s.empty? && !self.proxy[:port].to_s.empty?
          proxy_options[:uri]       =   "http://#{self.proxy[:host]}:#{self.proxy[:port]}"
          proxy_options[:user]      =   self.proxy[:username] if !self.proxy[:username].to_s.empty?
          proxy_options[:password]  =   self.proxy[:password] if !self.proxy[:password].to_s.empty?
        end
        
        return proxy_options
      end

    end
  end
end
