namespace :http_utilities do
  namespace :proxies do
    desc "Proxy tasks"

    task :seed_proxies => :environment do |task, args|
      seeder = HttpUtilities::Proxies::ProxySeeder.new
      seeder.seed
    end

    task :check_proxies, [:protocol, :proxy_type, :mode, :maximum_failed_attempts] => [:environment] do |task, args|
      args.with_defaults(protocol: :http, proxy_type: :public, mode: :synchronous, maximum_failed_attempts: 10)
      
      proxy_checker = HttpUtilities::Proxies::ProxyChecker.new
      proxy_checker.check_and_update_proxies(
        protocol:                 args.protocol.to_sym, 
        proxy_type:               args.proxy_type.to_sym, 
        mode:                     args.mode.to_sym,
        maximum_failed_attempts:  args.maximum_failed_attempts.to_i
      )
    end
  end
end