# -*- encoding : utf-8 -*-
module HttpUtilities
  VERSION = "1.2.6"
  
  require File.join(File.dirname(__FILE__), 'http_utilities/railtie') if defined?(Rails)

  require File.join(File.dirname(__FILE__), 'http_utilities/http/proxy_support')
  require File.join(File.dirname(__FILE__), 'http_utilities/http/user_agent')
  require File.join(File.dirname(__FILE__), 'http_utilities/http/logger')

  require File.join(File.dirname(__FILE__), 'http_utilities/http/request')
  require File.join(File.dirname(__FILE__), 'http_utilities/http/response')

  require File.join(File.dirname(__FILE__), 'http_utilities/http/client')

  require File.join(File.dirname(__FILE__), 'http_utilities/http/mechanize/client')

  if defined?(ActiveRecord)
    require File.join(File.dirname(__FILE__), 'http_utilities/proxies/mysql/proxy_module')
    require File.join(File.dirname(__FILE__), 'http_utilities/proxies/proxy_seeder')
  end
  
  if defined?(Mongoid)
    require File.join(File.dirname(__FILE__), 'http_utilities/proxies/mongo/proxy_module')
  end
  
  require File.join(File.dirname(__FILE__), 'http_utilities/proxies/proxy_checker')
  
  if defined?(Resque)
    require File.join(File.dirname(__FILE__), 'http_utilities/jobs/resque/proxies/check_proxies_job')
    require File.join(File.dirname(__FILE__), 'http_utilities/jobs/resque/proxies/check_proxy_job')
  end
  
  if defined?(Sidekiq)
    require File.join(File.dirname(__FILE__), 'http_utilities/jobs/sidekiq/proxies/check_proxies_job')
    require File.join(File.dirname(__FILE__), 'http_utilities/jobs/sidekiq/proxies/check_proxy_job')
  end
end