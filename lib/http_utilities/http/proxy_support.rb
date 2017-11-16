module HttpUtilities
  module Http
    module ProxySupport

      def set_proxy_options(options = {})
        proxy_opts                    =   options.fetch(:proxy, nil)
        
        if proxy_opts
          self.proxy                ||=   {}
          
          if proxy_opts.is_a?(String)
            set_from_string(proxy_opts)
            
          elsif proxy_opts.is_a?(Hash)
            set_from_hash(proxy_opts)
            
          elsif proxy_model_defined? && proxy_opts.is_a?(::Proxy)
            set_from_object(proxy_opts)
          end
        end
      end
      
      def set_from_string(proxy_opts)
        proxy_opts                    =   proxy_opts.gsub(/^http(s)?:\/\//i, "")
        parts                         =   proxy_opts.split(":")

        if parts.size.eql?(2)
          self.proxy[:host]           =   parts.first
          self.proxy[:port]           =   parts.second.to_i
        end
      end
      
      def set_from_hash(proxy_opts)
        host                          =   proxy_opts.fetch(:host, nil)
        port                          =   proxy_opts.fetch(:port, nil)
        
        username                      =   proxy_opts.fetch(:username, nil)
        password                      =   proxy_opts.fetch(:password, nil)
        credentials                   =   proxy_opts.fetch(:credentials, nil)
        
        randomize                     =   proxy_opts.fetch(:randomize, true)
        type                          =   proxy_opts.fetch(:type, :all)
        protocol                      =   proxy_opts.fetch(:protocol, :all)
        
        if randomize && proxy_model_defined?
          proxy_object                =   ::Proxy.get_random_proxy(protocol: protocol, proxy_type: type)
          set_from_object(proxy_object)
        else
          if host && port
            self.proxy[:host]         =   host
            self.proxy[:port]         =   port
            
            set_credentials(username, password)
          end
        end
      end
      
      def set_from_object(proxy_object)
        if proxy_object
          self.proxy[:host]           =   proxy_object.host
          self.proxy[:port]           =   proxy_object.port
          username                    =   !proxy_object.username.to_s.empty? ? proxy_object.username : nil
          password                    =   !proxy_object.password.to_s.empty? ? proxy_object.password : nil
          
          set_credentials(username, password)
        end
      end

      def set_credentials(username, password, credentials = {})
        if username && password
          self.proxy[:username]       =   username
          self.proxy[:password]       =   password

        elsif credentials
          if credentials.is_a?(Hash)
            self.proxy[:username]     =   credentials[:username]
            self.proxy[:password]     =   credentials[:password]

          elsif (credentials.is_a?(String))
            parts                     =   credentials.split(":")

            if parts && parts.any? && parts.size == 2
              self.proxy[:username]   =   parts.first
              self.proxy[:password]   =   parts.second
            end
          end
        end
      end
      
      def proxy_model_defined?
        defined                       =   Module.const_get("Proxy").is_a?(Class) rescue false
        defined                       =   (defined && ::Proxy.respond_to?(:get_random_proxy))
        
        return defined
      end
      
      def generate_proxy_options
        proxy_options                 =   {}
        
        if self.proxy && !self.proxy[:host].to_s.empty? && !self.proxy[:port].to_s.empty?
          proxy_options[:uri]         =   "http://#{self.proxy[:host]}:#{self.proxy[:port]}"
          proxy_options[:user]        =   self.proxy[:username] if !self.proxy[:username].to_s.empty?
          proxy_options[:password]    =   self.proxy[:password] if !self.proxy[:password].to_s.empty?
        end
        
        return proxy_options
      end

    end
  end
end
