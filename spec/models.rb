require "active_record"
require File.expand_path('../../lib/http_utilities/proxies/sql/proxy_module', __FILE__)

class Proxy < ActiveRecord::Base
  include HttpUtilities::Proxies::Sql::ProxyModule
end
