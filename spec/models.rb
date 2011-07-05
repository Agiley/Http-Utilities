require "active_record"
require File.expand_path('../../lib/http_utilities/proxies/proxy', __FILE__)

class Proxy < ActiveRecord::Base
  include HttpUtilities::Proxies::Proxy
end