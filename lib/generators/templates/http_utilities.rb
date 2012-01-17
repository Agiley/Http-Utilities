HttpUtilities.setup do |config|
  config.default_http_library         =   :net_http
  config.check_proxies_using_resque   =   true
end