# -*- encoding : utf-8 -*-

module HttpUtilities
  module Proxies
    class ProxyChecker
      require 'activerecord-import'
      attr_accessor :client, :processed_proxies
      attr_accessor :limit, :minimum_successful_attempts, :maximum_failed_attempts

      def initialize
        self.client = HttpUtilities::Http::Client.new
        self.processed_proxies = []
        
        self.limit = 1000
        self.minimum_successful_attempts = 1
        self.maximum_failed_attempts = 2
      end

      def check_and_update_proxies(protocol = :all, proxy_type = :all, mode = :synchronous)
        check_proxies(protocol, proxy_type, mode)
        update_proxies
      end

      def check_proxies(protocol = :all, proxy_type = :all, mode = :synchronous)
        proxies = Proxy.should_be_checked(protocol, proxy_type, Time.now, self.limit)

        if (proxies && proxies.any?)
          Rails.logger.info "Found #{proxies.size} #{proxy_type} proxies to check."

          proxies.each do |proxy|
            case mode
              when :synchronous
                check_proxy(proxy)
              when :resque
                Resque.enqueue(HttpUtilities::Jobs::Proxies::CheckProxyJob, proxy.id)
              when :sidekiq
                HttpUtilities::Jobs::Proxies::CheckProxyJob.perform_async(proxy.id)
            end
          end

        else
          Rails.logger.info "Couldn't find any proxies to check!"
        end
      end
      
      def check_proxy(proxy, timeout = 60)
        document = nil
        valid_proxy = false

        options = {:method              =>  :net_http,
                   :use_proxy           =>  true, 
                   :proxy               =>  proxy.proxy_address, 
                   :proxy_protocol      =>  proxy.protocol,
                   :timeout             =>  timeout,
                   :maximum_redirects   =>  1,
                   :disable_auth        =>  true
                  }

        Rails.logger.info "#{Time.now}: Fetching Proxy #{proxy.proxy_address}."

        response = self.client.retrieve_parsed_html("http://www.google.com/webhp?hl=en", options)

        if (response && response.parsed_body)
          title = response.parsed_body.css("title").first

          if (title && title.content)
            begin
              title = title.content.encode("UTF-8")
              valid_proxy = (title && title.strip.downcase.eql?("google"))
              Rails.logger.info "Title is: #{title}. Proxy #{proxy.proxy_address} "
            rescue Exception => e
              Rails.logger.error "Exception occured while trying to validate proxy. Error Class: #{e.class}. Error Message: #{e.message}"
              valid_proxy = false
            end
          end
        end

        if (valid_proxy)
          Rails.logger.info "#{Time.now}: Proxy #{proxy.proxy_address} is working!"
        else
          Rails.logger.info "#{Time.now}: Proxy #{proxy.proxy_address} is not working!"
        end

        self.processed_proxies << {:proxy => proxy, :valid => valid_proxy}
      end

      def update_proxies()
        columns = [:host, :port, :last_checked_at, :valid_proxy, :successful_attempts, :failed_attempts]
        values = []

        Rails.logger.info "Updating/Importing #{self.processed_proxies.size} proxies"

        if (self.processed_proxies && self.processed_proxies.any?)
          self.processed_proxies.each do |value|
            proxy = value[:proxy]
            valid = value[:valid]
            successful_attempts = proxy.successful_attempts
            failed_attempts = proxy.failed_attempts

            if (valid)
              successful_attempts += 1
            else
              failed_attempts += 1
            end

            is_valid = (successful_attempts >= self.minimum_successful_attempts && failed_attempts < self.maximum_failed_attempts)
            value_arr = [proxy.host, proxy.port, Time.now, is_valid, successful_attempts, failed_attempts]
            values << value_arr
          end

          ::Proxy.import(columns, values, :on_duplicate_key_update => [:last_checked_at, :valid_proxy, :successful_attempts, :failed_attempts], :validate => false)
        end

      end
      
      def processing_method(method = nil)
        if (method.nil? || method.to_sym.eql?(:jobs))
          method = (defined?(Resque)) ? :jobs : :iterate
        end
        
        return method
      end

    end
  end
end