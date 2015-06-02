# -*- encoding : utf-8 -*-

require 'socket'
require 'net/ssh/proxy/socks5'
require 'activerecord-import'

module HttpUtilities
  module Proxies
    class ProxyChecker
      attr_accessor :client, :processed_proxies
      attr_accessor :limit, :minimum_successful_attempts, :maximum_failed_attempts

      def initialize
        self.client                       =   HttpUtilities::Http::Client.new

        self.processed_proxies            =   []
        
        self.limit                        =   1000
        self.minimum_successful_attempts  =   1
        self.maximum_failed_attempts      =   10
      end

      def check_and_update_proxies(protocol: :all, proxy_type: :all, mode: :synchronous, maximum_failed_attempts: self.maximum_failed_attempts)
        check_proxies(protocol: protocol, proxy_type: proxy_type, mode: mode, maximum_failed_attempts: maximum_failed_attempts)
        update_proxies
      end

      def check_proxies(protocol: :all, proxy_type: :all, mode: :synchronous, maximum_failed_attempts: self.maximum_failed_attempts)
        proxies                           =   Proxy.should_be_checked(
          protocol:                 protocol,
          proxy_type:               proxy_type,
          date:                     Time.now,
          limit:                    self.limit,
          maximum_failed_attempts:  maximum_failed_attempts
        )

        if (proxies && proxies.any?)
          Rails.logger.info "Found #{proxies.size} #{proxy_type} proxies to check."

          proxies.each do |proxy|
            case mode
              when :synchronous
                check_proxy(proxy)
              when :resque
                Resque.enqueue(HttpUtilities::Jobs::Resque::Proxies::CheckProxyJob, proxy.id)
              when :sidekiq
                HttpUtilities::Jobs::Sidekiq::Proxies::CheckProxyJob.perform_async(proxy.id)
            end
          end

        else
          Rails.logger.info "Couldn't find any proxies to check!"
        end
      end
      
      def check_proxy(proxy)
        Rails.logger.info "#{Time.now}: Will check if proxy #{proxy.proxy_address} is working."
        
        self.send("check_#{proxy.protocol}_proxy", proxy)
      end
      
      def check_socks_proxy(proxy, test_host: "whois.verisign-grs.com", test_port: 43, test_query: "=google.com")
        valid_proxy     =   false

        begin
          socks_proxy   =   Net::SSH::Proxy::SOCKS5.new(proxy.host, proxy.port, proxy.socks_proxy_credentials)
          client        =   socks_proxy.open(test_host, test_port)
  
          client.write("#{test_query}\r\n")
          response      =   client.read
          
          valid_proxy   =   (response && response.present?)
        
        rescue StandardError => e
          Rails.logger.error "Exception occured while trying to check proxy #{proxy.proxy_address}. Error Class: #{e.class}. Error Message: #{e.message}"
          valid_proxy   =   false
        end
        
        if (valid_proxy)
          Rails.logger.info "#{Time.now}: Proxy #{proxy.proxy_address} is working!"
        else
          Rails.logger.info "#{Time.now}: Proxy #{proxy.proxy_address} is not working!"
        end

        self.processed_proxies << {proxy: proxy, valid: valid_proxy}
      end
      
      def check_http_proxy(proxy, test_url: "http://www.google.com/robots.txt", timeout: 10)
        options       =   {
                            use_proxy:       true,
                            proxy:           {host: proxy.host, port: proxy.port}, 
                            proxy_protocol:  proxy.protocol,
                            timeout:         timeout
                          }
        
        options.merge!(proxy_username: proxy.username) if proxy.username && proxy.username.present?
        options.merge!(proxy_password: proxy.password) if proxy.password && proxy.password.present?

        Rails.logger.info "#{Time.now}: Fetching robots.txt for Google.com with proxy #{proxy.proxy_address}. Using authentication? #{options.has_key?(:proxy_username).to_s}"
        
        response       =   self.client.get(test_url, options: options)
        valid_proxy    =   (response && response.body && response.body =~ /Allow: \/search\/about/i)

        if (valid_proxy)
          Rails.logger.info "#{Time.now}: Proxy #{proxy.proxy_address} is working!"
        else
          Rails.logger.info "#{Time.now}: Proxy #{proxy.proxy_address} is not working!"
        end

        self.processed_proxies << {proxy: proxy, valid: valid_proxy}
      end

      def update_proxies
        columns   =   [:host, :port, :last_checked_at, :valid_proxy, :successful_attempts, :failed_attempts]
        values    =   []

        Rails.logger.info "Updating/Importing #{self.processed_proxies.size} proxies"

        if (self.processed_proxies && self.processed_proxies.any?)
          self.processed_proxies.each do |value|
            proxy                 =   value[:proxy]
            valid                 =   value[:valid]
            successful_attempts   =   proxy.successful_attempts
            failed_attempts       =   proxy.failed_attempts

            if (valid)
              successful_attempts +=  1
            else
              failed_attempts     +=  1
            end

            is_valid              =   (successful_attempts >= self.minimum_successful_attempts && failed_attempts < self.maximum_failed_attempts)
            value_arr             =   [proxy.host, proxy.port, Time.now, is_valid, successful_attempts, failed_attempts]
            values                <<  value_arr
          end

          ::Proxy.import(columns, values, :on_duplicate_key_update => [:last_checked_at, :valid_proxy, :successful_attempts, :failed_attempts], :validate => false)
        end

      end

    end
  end
end