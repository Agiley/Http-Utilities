class Proxy < ActiveRecord::Base
  include HttpUtilities::Proxies::Proxy  
end