class Proxy < ActiveRecord::Base
  include HttpUtilities::Proxies::ProxyModule  
end