namespace :http_utilities do
  namespace :proxies do
    desc "Proxy tasks"

    task :check_proxies, :proxy_type, :needs => :environment do |task, args|
      proxy_type = args.proxy_type.to_s
      proxy_checker = HttpUtilities::Proxies::ProxyChecker.new.check_and_update_proxies(public_proxies)
    end
  end
end