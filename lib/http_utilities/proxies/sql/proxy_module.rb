module HttpUtilities
  module Proxies
    module Sql
      
      module ProxyModule
      
        def self.included(base)
          base.send :extend, ClassMethods
          base.send :include, InstanceMethods
        end

        module ClassMethods
          def should_be_checked(protocol: :all, proxy_type: :all, date: Time.now, limit: 10, maximum_failed_attempts: 10)
            proxies     =   get_proxies_for_protocol_and_proxy_type(protocol, proxy_type)
            proxies     =   proxies.where(["(last_checked_at IS NULL OR last_checked_at < ?)", date])
            proxies     =   proxies.where(["failed_attempts <= ?", maximum_failed_attempts])
            proxies     =   proxies.order("valid_proxy ASC, failed_attempts ASC, last_checked_at ASC")
            proxies     =   proxies.limit(limit)
          
            return proxies
          end
        
          def get_valid_proxies(protocol: :all, proxy_type: :all, maximum_failed_attempts: nil)
            proxies     =   get_proxies_for_protocol_and_proxy_type(protocol, proxy_type)
            proxies     =   proxies.where(["valid_proxy = ? AND last_checked_at IS NOT NULL", true])
            proxies     =   proxies.where(["failed_attempts <= ?", maximum_failed_attempts]) if maximum_failed_attempts

            return proxies
          end
        
          def get_random_proxy(protocol: :all, proxy_type: :all, maximum_failed_attempts: nil)
            proxies     =   get_valid_proxies(protocol: protocol, proxy_type: proxy_type, maximum_failed_attempts: maximum_failed_attempts)
          
            order_clause = case ActiveRecord::Base.connection.class.name
              when "ActiveRecord::ConnectionAdapters::MysqlAdapter", "ActiveRecord::ConnectionAdapters::Mysql2Adapter"
                "RAND() DESC"
              when "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter"
                "RANDOM() DESC"
              when "ActiveRecord::ConnectionAdapters::SQLite3Adapter"
                "RANDOM() DESC"
              else
                "RAND() DESC"
            end
          
            proxies     =   proxies.order(order_clause)
          
            proxy       =   nil
          
            uncached do
              proxy     =   proxies.limit(1).first
            end

            return proxy
          end
        
          def get_proxies_for_protocol_and_proxy_type(protocol, proxy_type)
            proxies     =   ::Proxy.where(nil)
            proxies     =   proxies.where(protocol: protocol)     if (protocol && !protocol.downcase.to_sym.eql?(:all))
            proxies     =   proxies.where(proxy_type: proxy_type) if (proxy_type && !proxy_type.downcase.to_sym.eql?(:all))
          
            return proxies
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
        
          def socks_proxy_credentials
            credentials     =   {}
          
            if (!self.username.empty? && !self.password.empty?)
              credentials   =   {user: self.username, password: self.password}
            elsif (!self.username.empty? && self.password.empty?)
              credentials   =   {user: self.username}
            end
          
            return credentials
          end
          
          def proxy_options_for_faraday
            proxy_options             =   {}
        
            proxy_options[:uri]       =   ::Proxy.format_proxy_address(self.host, self.port, true)
            proxy_options[:user]      =   self.username if self.username && !self.username.empty?
            proxy_options[:password]  =   self.password if self.password && !self.password.empty?
        
            return proxy_options
          end
        end
      
      end
      
    end
  end
end