# -*- encoding : utf-8 -*-

module HttpUtilities
  module Http
    class Client
      include HttpUtilities::Http::Logger
      
      EXCEPTIONS        =   [
        Faraday::Error
      ]
      
      def get(url, arguments: {}, options: {}, raise_exceptions: false, retries: 3)
        response        =   nil
        
        begin
          request       =   build_request(options: options)
          response      =   request.interface.get(url, arguments)
          response      =   HttpUtilities::Http::Response.new(response: response, request: request, options: options)
    
        rescue *EXCEPTIONS => e
          log(:error, "[HttpUtilities::Http::Client] - An error occurred while trying to fetch the response. Error Class: #{e.class.name}. Error Message: #{e.message}.")
          retries      -=   1
          retry if retries > 0
          raise e if raise_exceptions && retries == 0
        end

        return response
      end
      
      def post(url, data: nil, options: {}, raise_exceptions: false, retries: 3)
        response        =   nil
    
        begin
          request       =   build_request(options: options)
          response      =   request.interface.post(url, data)
          response      =   HttpUtilities::Http::Response.new(response: response, request: request, options: options)
    
        rescue *EXCEPTIONS => e
          log(:error, "[HttpUtilities::Http::Client] - An error occurred while trying to fetch the response. Error Class: #{e.class.name}. Error Message: #{e.message}.")
          retries          -=   1
          retry if retries > 0
          raise e if raise_exceptions && retries == 0
        end

        return response
      end
      
      private
      def build_request(options: {}, client_options: {})
        client_options                      =   client_options.merge(ssl: {verify: false})
        
        adapter                             =   options.fetch(:adapter, Faraday.default_adapter)
        timeout                             =   options.fetch(:timeout, 60)
        open_timeout                        =   options.fetch(:open_timeout, 60)
        follow_redirects_limit              =   options.fetch(:follow_redirects_limit, nil)
        request_headers                     =   options.fetch(:request_headers, {})
        response_adapters                   =   options.fetch(:response_adapters, [])
        
        request                             =   HttpUtilities::Http::Request.new(options: options)
        request.set_proxy_options(options)
        proxy_options                       =   request.generate_proxy_options
        
        connection      =   Faraday.new(client_options) do |builder|
          builder.headers[:user_agent]      =   request.user_agent

          request_headers.each do |key, value|
            builder.headers[key]            =   value 
          end if request_headers && !request_headers.empty?
          
          builder.options[:timeout]         =   timeout if timeout
          builder.options[:open_timeout]    =   open_timeout if open_timeout
          
          builder.use       FaradayMiddleware::FollowRedirects, limit: follow_redirects_limit unless follow_redirects_limit.nil?
          
          response_adapters.each do |response_adapter|
            builder.send(:response, response_adapter)
          end if response_adapters && response_adapters.any?

          builder.proxy                     =   proxy_options if proxy_options && !proxy_options.empty?
          
          builder.adapter   adapter
        end

        request.interface                   =   connection
        
        return request
      end
      
    end
  end
end
