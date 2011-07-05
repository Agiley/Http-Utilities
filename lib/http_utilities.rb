# -*- encoding : utf-8 -*-
module HttpUtilities
  require File.join(File.dirname(__FILE__), 'http_utilities/railtie') if defined?(Rails)
  
  mattr_accessor :default_http_library
  @@default_http_library = :net_http

  def self.setup
    yield self
  end
  
  require File.join(File.dirname(__FILE__), 'http_utilities/http/net_http')
  require File.join(File.dirname(__FILE__), 'http_utilities/http/open_uri')
  require File.join(File.dirname(__FILE__), 'http_utilities/http/curb')
  require File.join(File.dirname(__FILE__), 'http_utilities/http/proxy')
  require File.join(File.dirname(__FILE__), 'http_utilities/http/client')
  
  require File.join(File.dirname(__FILE__), 'http_utilities/proxies/proxy_checker')
  
  require File.join(File.dirname(__FILE__), 'http_utilities/jobs/proxies/check_proxies_job')
  require File.join(File.dirname(__FILE__), 'http_utilities/jobs/proxies/check_proxy_job')
end
