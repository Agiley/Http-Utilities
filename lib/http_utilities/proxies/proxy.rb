module HttpUtilities
  module Proxies
    module Proxy
      
      def self.included(base)
        
        base.scope :should_be_checked, lambda { |public_proxies, date, limit| 
          where("public = ? AND (last_checked_at IS NULL OR last_checked_at < ?) AND failed_attempts <= ? AND protocol = ?", public_proxies, date, 10, "http").order("valid_proxy ASC, failed_attempts ASC, last_checked_at ASC").limit(limit) 
        }
        
        base.send :extend, ClassMethods
        base.send :include, InstanceMethods
      end

      module ClassMethods


        def get_random_proxy(protocol = :all, type = :all)
          proxy           =   nil
          protocol_where  =   (!protocol.eql?(:all)) ? " AND protocol = '#{protocol.to_s}'" : ""
          public_where    =   (!type.eql?(:all)) ? " AND public = #{type.eql?(:public)}" : ""

          uncached do
            proxy = where("valid_proxy = 1 AND last_checked_at IS NOT NULL#{protocol_where}#{public_where}").order("successful_attempts DESC, failed_attempts ASC, RAND() DESC").limit(1).first rescue nil
          end

          return proxy
        end

        def format_proxy_address(proxy_host, proxy_port = 80, include_http = false)
          proxy_address = "#{proxy_host}:#{proxy_port}"
          proxy_address.insert(0, "http://") if (include_http && !proxy_address.start_with?("http://"))
          return proxy_address
        end

        def format_proxy_credentials(username, password)
          return "#{username}:#{password}"
        end
      end

      module InstanceMethods
        def proxy_address(include_http = false)
          proxy_addr = "#{self.host}:#{self.port}"
          proxy_addr.insert(0, "http://") if (include_http && !proxy_addr.start_with?("http://"))
          return proxy_addr
        end
      end
      
    end
  end
end