namespace :http_utilities do
  namespace :proxies do
    desc "Proxy tasks"

    task :seed_proxies, :needs => :environment do |task, args|
      seeder = HttpUtilities::Proxies::ProxySeeder.new
      seeder.seed
    end

    task :check_proxies, :protocol, :proxy_type, :needs => :environment do |task, args|
      protocol = (args.protocol) ? args.protocol.to_s || "http"
      proxy_type = (args.proxy_type) ? args.proxy_type.to_s || "public"
      
      proxy_checker = HttpUtilities::Proxies::ProxyChecker.new
      proxy_checker.check_and_update_proxies(protocol, proxy_type)
    end
  end
end