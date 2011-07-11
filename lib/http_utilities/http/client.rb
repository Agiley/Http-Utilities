# -*- encoding : utf-8 -*-
require 'open-uri'
require 'net/http'
require 'uri'
require 'cgi'
require 'iconv'

module HttpUtilities
  module Http
    class Client
      include HttpUtilities::Http::NetHttp
      include HttpUtilities::Http::OpenUri
      include HttpUtilities::Http::Curb
      include HttpUtilities::Http::Proxy
      include HttpUtilities::Http::Cookies
      include HttpUtilities::Http::UserAgent
      include HttpUtilities::Http::Request
      include HttpUtilities::Http::Get
      include HttpUtilities::Http::Post
      include HttpUtilities::Http::Format
      
      attr_accessor :mutex, :user_agents, :proxy, :cookies
      
      def initialize
        self.mutex          =   Mutex.new
        self.proxy          =   {}
        self.cookies        =   nil
        
        set_user_agents
      end
    end
  end
end