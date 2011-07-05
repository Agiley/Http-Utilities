require 'open-uri'
require 'uri'

module HttpUtilities
  module Http
    module Proxy
      
      def set_proxy_options(proxy_options = {})
        options                   =   (proxy_options.is_a?(Hash)) ? proxy_options.clone() : {}

        use_proxy                 =   options.delete(:use_proxy) { |e| false }
        proxy                     =   options.delete(:proxy) { |e| nil }
        proxy_username            =   options.delete(:proxy_username) { |e| nil }
        proxy_password            =   options.delete(:proxy_password) { |e| nil }
        proxy_credentials         =   options.delete(:proxy_credentials) { |e| nil }
        reset_proxy               =   options.delete(:reset_proxy) { |e| true }

        if (reset_proxy)
          self.mutex.synchronize do
            self.proxy              =   {}
            self.proxy[:host]       =   options.delete(:proxy_host) { |e| nil }
            self.proxy[:port]       =   options.delete(:proxy_port) { |e| nil }
            self.proxy[:protocol]   =   options.delete(:proxy_protocol) { |e| :http }
            self.proxy[:type]       =   options.delete(:proxy_type) { |e| :all }
          end
        end

        if ((use_proxy || (proxy && proxy.present?)) && !self.using_proxy?)
          self.mutex.synchronize do
            if (proxy && proxy.present?)
              proxy = proxy.gsub(/^http(s)?:\/\//i, "")
              parts = proxy.split(":")

              self.proxy[:host] = parts.first rescue nil
              self.proxy[:port] = parts.second.to_i rescue nil
            else
              proxy_object = ::Proxy.get_random_proxy(self.proxy[:protocol], self.proxy[:type])

              if (proxy_object)
                self.proxy[:host] = proxy_object.host
                self.proxy[:port] = proxy_object.port
              end
            end
          end
        end

        if (self.using_proxy? && (!self.proxy[:username] || !self.proxy[:password]))
          self.mutex.synchronize do
            if (proxy_username && proxy_username.present? && proxy_password && proxy_password.present?)
              self.proxy[:username] = proxy_username
              self.proxy[:password] = proxy_password
            elsif (proxy_credentials)
              if (proxy_credentials.is_a?(Hash))
                self.proxy[:username] = proxy_credentials[:username] rescue nil
                self.proxy[:password] = proxy_credentials[:password] rescue nil
              elsif (proxy_credentials.is_a?(String))
                parts = proxy_credentials.split(":")
                self.proxy[:username] = parts.first rescue nil
                self.proxy[:password] = parts.second rescue nil
              end
            end
          end
        end

        if (self.using_proxy?)
          puts "\nUsing proxy #{self.proxy[:host]}:#{self.proxy[:port]}\n"
        else
          #puts "\nNOT USING PROXY!\n"
        end
      end

      def using_proxy?
        return (self.proxy[:host] && self.proxy[:host].present? && self.proxy[:port] && self.proxy[:port] > 0)
      end
      
    end
  end
end