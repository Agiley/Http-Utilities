module HttpUtilities
  module Jobs
    module Sidekiq
      module Proxies
        class CheckProxiesJob
          include ::Sidekiq::Worker
          sidekiq_options :queue    =>  :proxies,
                          :unique   =>  false

          def perform(protocol = :all, proxy_type = :all, mode = :synchronous)
            HttpUtilities::Proxies::ProxyChecker.new.check_proxies(protocol: protocol.to_sym, proxy_type: proxy_type.to_sym, mode: mode.to_sym)
          end
        end
      end
    end
  end
end