module HttpUtilities
  module Jobs
    module Sidekiq
      module Proxies
        class CheckProxyJob
          include ::Sidekiq::Worker
          sidekiq_options :queue    =>  :proxies

          def perform(proxy_id)
            proxy_object = ::Proxy.find(proxy_id) rescue nil

            if (proxy_object)
              checker = HttpUtilities::Proxies::ProxyChecker.new
              checker.check_proxy(proxy_object)
              checker.update_proxies
            end
          end
        end
      end
    end
  end
end