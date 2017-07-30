class Proxy < ActiveRecord::Base
  include HttpUtilities::Proxies::Mysql::ProxyModule  
end