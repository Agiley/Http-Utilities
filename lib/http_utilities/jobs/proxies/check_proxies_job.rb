module HttpUtilities
  module Jobs
    module Proxies
      class CheckProxiesJob
        @queue = :proxies

        def self.perform(proxy_id)
          HttpUtilities::Proxies::ProxyChecker.new.check_proxies
        end
      end
    end
  end
end