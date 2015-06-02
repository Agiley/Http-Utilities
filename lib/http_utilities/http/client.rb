# -*- encoding : utf-8 -*-
require 'open-uri'
require 'uri'
require 'cgi'

module HttpUtilities
  module Http
    class Client
      include HttpUtilities::Http::Logger
      
      def get(url, arguments: {}, options: {}, retries: 3)
        response        =   nil
        request         =   build_request(options)
        
        begin
          response      =   request.interface.get(url, arguments)
          response      =   HttpUtilities::Http::Response.new(response, request, options)
    
        rescue Faraday::TimeoutError, Net::ReadTimeout, Timeout::Error, StandardError => e
          log(:error, "[HttpUtilities::Http::Client] - An error occurred while trying to fetch the response. Error Class: #{e.class.name}. Error Message: #{e.message}.")
          retries      -=   1
          retry if retries > 0
        end

        return response
      end
      
      def post(url, data: nil, options: {}, retries: 3)
        response        =   nil
        request         =   build_request(options)
    
        begin
          response      =   request.interface.post(url, data)
          response      =   HttpUtilities::Http::Response.new(response, request, options)
    
        rescue Faraday::TimeoutError, Net::ReadTimeout, Timeout::Error, StandardError => e
          log(:error, "[HttpUtilities::Http::Client] - An error occurred while trying to fetch the response. Error Class: #{e.class.name}. Error Message: #{e.message}.")
          retries          -=   1
          retry if retries > 0
        end

        return response
      end
      
      private
      def build_request(opts = {})
        options         =   opts.dup
        options         =   options.merge(ssl: {:verify => false})
        
        adapter         =   options.delete(:adapter)                { |opt| Faraday.default_adapter }
        timeout         =   options.delete(:timeout)                { |opt| 60 }
        open_timeout    =   options.delete(:open_timeout)           { |opt| 60 }
        
        request                             =   HttpUtilities::Http::Request.new
        request.set_proxy_options(options)
        
        proxy_options                       =   request.generate_proxy_options
    
        connection      =   Faraday.new(options) do |builder|
          builder.headers[:user_agent]      =   user_agent
          builder.options[:timeout]         =   timeout
          builder.options[:open_timeout]    =   open_timeout        
          #builder.response  :logger
          builder.proxy     proxy_options unless proxy_options.empty?
          builder.adapter   adapter
        end

        request.interface                   =   connection
        
        return request
      end
      
    end
  end
end

