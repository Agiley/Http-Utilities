require 'open-uri'
require 'uri'

module HttpUtilities
  module Http
    module Proxy

      def set_proxy_options(proxy_options = {})
        current_proxy             =   nil

        options                   =   (proxy_options.is_a?(Hash)) ? proxy_options.clone() : {}

        use_proxy                 =   options.delete(:use_proxy) { |e| false }
        proxy                     =   options.delete(:proxy) { |e| nil }
        proxy_username            =   options.delete(:proxy_username) { |e| nil }
        proxy_password            =   options.delete(:proxy_password) { |e| nil }
        proxy_credentials         =   options.delete(:proxy_credentials) { |e| nil }
        reset_proxy               =   options.delete(:reset_proxy) { |e| true }

        if (reset_proxy)
          current_proxy              =   {}
          current_proxy[:host]       =   options.delete(:proxy_host) { |e| nil }
          current_proxy[:port]       =   options.delete(:proxy_port) { |e| nil }
          current_proxy[:protocol]   =   options.delete(:proxy_protocol) { |e| :http }
          current_proxy[:type]       =   options.delete(:proxy_type) { |e| :all }
        end

        if ((use_proxy || (proxy && proxy.present?)) && !self.using_proxy?(current_proxy))
          if (proxy && proxy.present?)
            proxy = proxy.gsub(/^http(s)?:\/\//i, "")
            parts = proxy.split(":")

            if (parts.size.eql?(2))
              current_proxy[:host] = parts.first
              current_proxy[:port] = parts.second.to_i
            end

          else
            proxy_object = ::Proxy.get_random_proxy(current_proxy[:protocol], current_proxy[:type])

            if (proxy_object)
              current_proxy[:host] = proxy_object.host
              current_proxy[:port] = proxy_object.port
            end
          end
        end

        current_proxy = set_proxy_credentials(current_proxy, proxy_username, proxy_password, proxy_credentials)

        return current_proxy
      end

      def using_proxy?(proxy)
        return (proxy[:host] && proxy[:host].present? && proxy[:port] && proxy[:port] > 0)
      end

      def set_proxy_credentials(current_proxy, proxy_username, proxy_password, proxy_credentials)
        if (self.using_proxy?(current_proxy) && (!current_proxy[:username] || !current_proxy[:password]))
          if (proxy_username && proxy_username.present? && proxy_password && proxy_password.present?)
            current_proxy[:username] = proxy_username
            current_proxy[:password] = proxy_password

          elsif (proxy_credentials)
            if (proxy_credentials.is_a?(Hash))
              current_proxy[:username] = proxy_credentials[:username]
              current_proxy[:password] = proxy_credentials[:password]

            elsif (proxy_credentials.is_a?(String))
              parts = proxy_credentials.split(":")

              if (parts && parts.any? && parts.size >= 2)
                current_proxy[:username] = parts.first
                current_proxy[:password] = parts.second
              end

            end
          end
        end

        return current_proxy
      end

    end
  end
end

