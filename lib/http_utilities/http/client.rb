# -*- encoding : utf-8 -*-
require 'open-uri'
require 'net/http'
require 'uri'
require 'cgi'

module HttpUtilities
  module Http
    class Client
      include HttpUtilities::Http::Cookies
      include HttpUtilities::Http::Url
      include HttpUtilities::Http::Get
      include HttpUtilities::Http::Post
      include HttpUtilities::Http::Logger

      include HttpUtilities::Http::Adapters::NetHttp
      include HttpUtilities::Http::Adapters::OpenUri
      include HttpUtilities::Http::Adapters::Curb
    end
  end
end

