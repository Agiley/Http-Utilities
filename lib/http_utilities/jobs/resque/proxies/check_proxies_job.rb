module HttpUtilities
  module Jobs
    module Resque
      module Proxies
        class CheckProxiesJob
          @queue = :proxies

          def perform(protocol = :all, proxy_type = :all, mode = :synchronous)
            HttpUtilities::Proxies::ProxyChecker.new.check_proxies(protocol.to_sym, proxy_type.to_sym, mode.to_sym)
          end
        end
      end
    end
  end
end