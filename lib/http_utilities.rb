# -*- encoding : utf-8 -*-
module HttpUtilities
  require File.join(File.dirname(__FILE__), 'http_utilities/railtie') if defined?(Rails)
  
  require File.join(File.dirname(__FILE__), 'http_utilities/http/proxy')
  require File.join(File.dirname(__FILE__), 'http_utilities/http/cookies')
  require File.join(File.dirname(__FILE__), 'http_utilities/http/user_agent')
  require File.join(File.dirname(__FILE__), 'http_utilities/http/url')
  require File.join(File.dirname(__FILE__), 'http_utilities/http/format')
  require File.join(File.dirname(__FILE__), 'http_utilities/http/get')
  require File.join(File.dirname(__FILE__), 'http_utilities/http/post')
  require File.join(File.dirname(__FILE__), 'http_utilities/http/logger')
  
  require File.join(File.dirname(__FILE__), 'http_utilities/http/request')
  require File.join(File.dirname(__FILE__), 'http_utilities/http/response')
  
  require File.join(File.dirname(__FILE__), 'http_utilities/http/adapters/net_http')
  require File.join(File.dirname(__FILE__), 'http_utilities/http/adapters/open_uri')
  require File.join(File.dirname(__FILE__), 'http_utilities/http/adapters/curb')
  
  require File.join(File.dirname(__FILE__), 'http_utilities/http/client')
  
  require File.join(File.dirname(__FILE__), 'http_utilities/http/mechanize/client')
  
  if defined?(ActiveRecord)
    require File.join(File.dirname(__FILE__), 'http_utilities/proxies/proxy_module')
    require File.join(File.dirname(__FILE__), 'http_utilities/proxies/proxy_checker')
    require File.join(File.dirname(__FILE__), 'http_utilities/proxies/proxy_seeder')

    require File.join(File.dirname(__FILE__), 'http_utilities/jobs/proxies/check_proxies_job')
    require File.join(File.dirname(__FILE__), 'http_utilities/jobs/proxies/check_proxy_job')
  end

  MultiXml.parser = :nokogiri
end
