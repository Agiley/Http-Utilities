namespace :http_utilities do
  namespace :proxies do
    desc "Proxy tasks"

    task :seed_proxies => :environment do |task, args|
      seeder = HttpUtilities::Proxies::ProxySeeder.new
      seeder.seed
    end

    task :check_proxies, [:protocol, :proxy_type, :method] => [:environment] do |task, args|
      protocol    =   (args.protocol)     ?   args.protocol.to_sym    : :http
      proxy_type  =   (args.proxy_type)   ?   args.proxy_type.to_sym  : :public
      method      =   (args.method)       ?   args.method.to_sym      : :jobs
      
      proxy_checker = HttpUtilities::Proxies::ProxyChecker.new
      proxy_checker.check_and_update_proxies(protocol, proxy_type, method)
    end
  end
end