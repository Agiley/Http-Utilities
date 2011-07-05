# -*- encoding : utf-8 -*-

module HttpUtilities
  module Proxies
    class ProxyChecker
      attr_accessor :http_utility, :processed_proxies

      LIMIT = 1000
      MINIMUM_SUCCESSFUL_ATTEMPTS = 1
      MAXIMUM_FAILED_ATTEMPTS = 2

      def initialize
        self.http_utility = Http::HttpUtility.new
        self.processed_proxies = []
      end

      def check_and_update_proxies(public_proxies = true)
        check_proxies(public_proxies)
        update_proxies
      end

      def check_proxies(proxy_type = :public)
        is_public = proxy_type.eql?(:public)
        proxies = Proxy.should_be_checked(is_public, Time.now, LIMIT)

        if (proxies && proxies.any?)
          puts "Found #{proxies.size} #{proxy_type} proxies to check."

          proxies.each do |proxy|
            Resque.enqueue(::Proxies::CheckProxyJob, proxy.id)
          end

        else
          puts "Couldn't find any proxies to check!"
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

        puts "\n\n#{Time.now}: Fetching Proxy #{proxy.proxy_address}."

        parsed_html = self.http_utility.retrieve_parsed_html("http://www.google.com/webhp?hl=en", options)

        if (parsed_html)
          title = parsed_html.css("title").first

          if (title && title.content)
            begin
              title = title.content.encode("UTF-8")
              valid_proxy = (title && title.present? && title.strip.downcase.eql?("google"))
              puts "\n\n Title is: #{title}. Proxy #{proxy.proxy_address}\n\n "
            rescue Exception => e
              puts "Exception occured while trying to validate proxy. Error Class: #{e.class}. Error Message: #{e.message}"
              valid_proxy = false
            end
          end
        end

        if (valid_proxy)
          puts "\n\n#{Time.now}: Proxy #{proxy.proxy_address} is working!"
        else
          puts "\n\n#{Time.now}: Proxy #{proxy.proxy_address} is not working!"
        end

        self.processed_proxies << {:proxy => proxy, :valid => valid_proxy}
      end

      def update_proxies()
        columns = [:host, :port, :last_checked_at, :valid_proxy, :successful_attempts, :failed_attempts]
        values = []

        puts "Updating/Importing #{self.processed_proxies.size} proxies"

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

            is_valid = (successful_attempts >= MINIMUM_SUCCESSFUL_ATTEMPTS && failed_attempts < MAXIMUM_FAILED_ATTEMPTS)
            value_arr = [proxy.host, proxy.port, Time.now, is_valid, successful_attempts, failed_attempts]
            values << value_arr
          end

          Proxy.import(columns, values, :on_duplicate_key_update => [:last_checked_at, :valid_proxy, :successful_attempts, :failed_attempts], :validate => false)
        end

      end

    end
  end
end