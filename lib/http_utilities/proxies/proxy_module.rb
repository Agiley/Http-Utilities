module HttpUtilities
  module Proxies
    module ProxyModule
      
      def self.included(base)
        base.send :extend, ClassMethods
        base.send :include, InstanceMethods
      end

      module ClassMethods
        def should_be_checked(protocol = :all, proxy_type = :all, date = Time.now, limit = 10)
          conditions = set_protocol_and_proxy_type_conditions(protocol, proxy_type)
          conditions << ActiveRecord::Base.send(:sanitize_sql_array, ["(last_checked_at IS NULL OR last_checked_at < ?)", date])
          conditions << "failed_attempts <= 10"
          query = conditions.join(" AND ")
          
          where(query).order("valid_proxy ASC, failed_attempts ASC, last_checked_at ASC").limit(limit) 
        end
        
        def get_random_proxy(protocol = :all, proxy_type = :all)
          conditions = set_protocol_and_proxy_type_conditions(protocol, proxy_type)
          conditions << ActiveRecord::Base.send(:sanitize_sql_array, ["valid_proxy = ?", true])
          conditions << "last_checked_at IS NOT NULL"
          query = conditions.join(" AND ")
          
          order_clause = case ActiveRecord::Base.connection.class.name
            when "ActiveRecord::ConnectionAdapters::MysqlAdapter", "ActiveRecord::ConnectionAdapters::Mysql2Adapter" then "RAND() DESC"
            when "ActiveRecord::ConnectionAdapters::SQLite3Adapter" then "RANDOM() DESC"
          end
          
          proxy = nil
          
          uncached do
            proxy = where(query).order(order_clause).limit(1).first
          end

          return proxy
        end
        
        def set_protocol_and_proxy_type_conditions(protocol, proxy_type)
          conditions = []
          conditions << ActiveRecord::Base.send(:sanitize_sql_array, ["protocol = ?", protocol]) if (protocol && !protocol.downcase.to_sym.eql?(:all))
          conditions << ActiveRecord::Base.send(:sanitize_sql_array, ["proxy_type = ?", proxy_type]) if (proxy_type && !proxy_type.downcase.to_sym.eql?(:all))
          return conditions
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
          return ::Proxy.format_proxy_address(self.host, self.port, include_http)
        end
        
        def proxy_credentials
          return ::Proxy.format_proxy_credentials(self.username, self.password)
        end
      end
      
    end
  end
end