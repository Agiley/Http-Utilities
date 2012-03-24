module HttpUtilities
  module Jobs
    module Sidekiq
      module Proxies
        class CheckProxiesJob
          include ::Sidekiq::Worker
          queue :proxies

          def perform(protocol = :all, proxy_type = :all, mode = :synchronous)
            HttpUtilities::Proxies::ProxyChecker.new.check_proxies(protocol.to_sym, proxy_type.to_sym, mode.to_sym)
          end
        end
      end
    end
  end
end