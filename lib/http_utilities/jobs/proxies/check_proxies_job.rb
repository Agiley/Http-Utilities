module HttpUtilities
  module Jobs
    module Proxies
      class CheckProxiesJob
        @queue = :low

        def self.perform(proxy_id)
          Proxies::ProxyChecker.new.check_proxies
        end
      end
    end
  end
end