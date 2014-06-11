module HttpUtilities
  module Jobs
    module Sidekiq
      module Proxies
        class CheckProxyJob
          include ::Sidekiq::Worker
          sidekiq_options :queue    =>  :proxies

          def perform(proxy_id)
            proxy_object  =   ::Proxy.where(id: proxy_id).first

            if (proxy_object)
              checker     =   HttpUtilities::Proxies::ProxyChecker.new
              checker.check_proxy(proxy_object)
              checker.update_proxies
            end
          end
        end
      end
    end
  end
end