# -*- encoding : utf-8 -*-
require 'open-uri'
require 'net/http'
require 'uri'

module HttpUtilities
  module Http
    class Client
      include HttpUtilities::Http::NetHttp
      include HttpUtilities::Http::OpenUri
      include HttpUtilities::Http::Curb
      include HttpUtilities::Http::Proxy
      
      attr_accessor :mutex, :user_agents, :proxy, :cookies
      
      def initialize
        self.mutex          =   Mutex.new
        self.user_agents    =   YAML.load(File.read(File.join(Rails.root, "config/http_utilities", "user_agents.yml")))["user_agents"] rescue []
        self.proxy          =   {}
        self.cookies        =   nil
      end

      def retrieve_raw_content(url, options = {})
        response = retrieve_content_from_url(url, options)
        return response
      end

      def retrieve_raw_xml(url, options = {})
        response = retrieve_content_from_url(url, options)
        return response
      end

      def post_and_retrieve_content(url, data, options = {})
        response = nil

        method = options[:method] || :net_http

        if (method.eql?(:net_http))
          response = post_and_retrieve_content_using_net_http(url, options)
        elsif (method.eql?(:curl))
          response = post_and_retrieve_content_using_curl(url, options)
        end

        #puts "Raw response: #{response}\n\n"

        return response
      end

      def post_and_retrieve_parsed_html(url, data, options = {})
        response = post_and_retrieve_content(url, data, options)
        return (response && response.present?) ? Nokogiri::HTML(response, nil, "utf-8") : nil
      end

      def post_and_retrieve_parsed_xml(url, data, options = {})
        response = post_and_retrieve_content(url, data, options)
        return (response && response.present?) ? Nokogiri::XML(response, nil, "utf-8") : nil
      end

      def retrieve_parsed_xml(url, options = {})
        return as_xml(retrieve_content_from_url(url, options.merge!({:force_encoding => true})))
      end

      def retrieve_parsed_html(url, options = {})
        return as_html(retrieve_content_from_url(url, options.merge!({:force_encoding => true})))
      end

      def as_html(response)
        return (response && response.present?) ? Nokogiri::HTML(response, nil, "utf-8") : nil
      end

      def as_xml(response)
        return (response && response.present?) ? Nokogiri::XML(response, nil, "utf-8") : nil
      end

      def retrieve_parsed_html_and_fallback_to_proxies(url, options = {})
        retries = 0
        max_retries = options.delete(:maximum_retrieval_retries) { |e| 5 }

        response = retrieve_content_from_url(url, options.merge!({:force_encoding => true}))

        while (!response && retries < max_retries) do
          options.merge!({:use_proxy => true})
          puts "Falling back to using proxies..."
          response = retrieve_content_from_url(url, options)
          retries += 1
        end

        parsed_html = (response && response.present?) ? Nokogiri::HTML(response, nil, "utf-8") : nil

        return parsed_html
      end

      def retrieve_raw_content_and_fallback_to_proxies(url, options = {})
        retries = 0
        max_retries = options.delete(:maximum_retrieval_retries) { |e| 5 }

        response = retrieve_content_from_url(url, options.merge!({:force_encoding => true}))

        while (!response && retries < max_retries) do
          options.merge!({:use_proxy => true})
          puts "Falling back to using proxies..."
          response = retrieve_content_from_url(url, options)
          retries += 1
        end

        return response
      end

      def retrieve_content_from_url(url, options = {})
        response = nil

        method = options[:method] || :net_http

        if (method.eql?(:open_uri))
          response = retrieve_open_uri_content(url, options)
        elsif (method.eql?(:net_http))
          response = retrieve_net_http_content(url, options)
        elsif (method.eql?(:curl))
          response = retrieve_curl_content(url, options)
        end

        #puts "Raw response: #{response}\n\n"

        return response
      end

      def format_cookies(cookies)
        cookie_string = ""
        cookies.each {|cookie| cookie_string += "#{cookie}; "}

        return cookie_string
      end

      def randomize_user_agent_string
        user_agent = (self.user_agents && self.user_agents.any?) ? self.user_agents[rand(self.user_agents.size)] : ""
        return user_agent
      end

      def generate_request_url(params = {})
        params.symbolize_keys!
        url = params.delete(:url) { |e| "" }

        sorted_params = params.sort
        query_parts = []

        sorted_params.each do |param_row|
          param = encode_param(param_row.first)
          value = encode_param(param_row.last)
          query_parts << "#{param}=#{value}"
        end

        query = query_parts.join("&")
        request = "#{url}?#{query}"
        puts "Sending request: #{request}\n"
        return request
      end

      def encode_param(param)
        return CGI.escape(param.to_s).to_s.gsub("+", "%20").gsub("%7E", "~") if (param && param.present?)
      end

    end
    
  end
end