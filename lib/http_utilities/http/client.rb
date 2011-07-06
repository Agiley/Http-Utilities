# -*- encoding : utf-8 -*-
require 'open-uri'
require 'net/http'
require 'uri'
require 'cgi'

module HttpUtilities
  module Http
    class Client
      include HttpUtilities::Http::NetHttp
      include HttpUtilities::Http::OpenUri
      include HttpUtilities::Http::Curb
      include HttpUtilities::Http::Proxy
      include HttpUtilities::Http::Cookies
      include HttpUtilities::Http::Get
      include HttpUtilities::Http::Post
      
      attr_accessor :mutex, :user_agents, :proxy, :cookies
      
      def initialize
        self.mutex          =   Mutex.new
        self.proxy          =   {}
        self.cookies        =   nil
        
        set_user_agents
      end
      
      def set_user_agents
        agents = YAML.load(File.read(File.join(Rails.root, "config/http_utilities", "user_agents.yml")))["user_agents"] rescue nil
        agents ||= YAML.load(File.read(File.join(File.dirname(__FILE__), "../../generators/templates/user_agents.yml")))["user_agents"] rescue nil
        self.user_agents = agents if (agents && agents.any?)
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
      
      def generate_request_params(params)
        sorted_params = params.sort
        query_parts = []

        sorted_params.each do |param_row|
          param = param_row.first
          value = param_row.last
          query_parts << "#{param}=#{value}"
        end

        query = query_parts.join("&")
        
        return query
      end

      def encode_param(param)
        return CGI.escape(param.to_s).to_s.gsub("+", "%20").gsub("%7E", "~") if (param && param.present?)
      end

    end
    
  end
end