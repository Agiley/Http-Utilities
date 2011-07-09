module HttpUtilities
  module Jobs
    module Proxies
      class CheckProxiesJob
        @queue = :proxies

        def self.perform(protocol = :all, proxy_type = :all)
          HttpUtilities::Proxies::ProxyChecker.new.check_proxies(protocol, proxy_type)
        end
      end
    end
  end
end