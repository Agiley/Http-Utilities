module HttpUtilities
  module Proxies
    module Proxy
      
      def self.included(base)
        base.send :extend, ClassMethods
        base.send :include, InstanceMethods
      end

      module ClassMethods
        def should_be_checked(protocol = :all, proxy_type = :all, date = Time.now, limit = 10)
          conditions = []
          conditions << "protocol = '#{protocol.to_s}'" if (protocol && !protocol.downcase.to_sym.eql?(:all))
          conditions << "proxy_type = '#{proxy_type.to_s}'" if (proxy_type && !proxy_type.downcase.to_sym.eql?(:all))
          conditions << "(last_checked_at IS NULL OR last_checked_at < '#{date.to_s(:db)}')"
          conditions << "failed_attempts <= 10"
          query = conditions.join(" AND ")
          
          puts "QUERY: #{query.inspect}"
          
          where(query).order("valid_proxy ASC, failed_attempts ASC, last_checked_at ASC").limit(limit) 
        end
        
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