Gem::Specification.new do |s|
  s.specification_version     = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5") if s.respond_to? :required_rubygems_version=
  
  s.name = "http_utilities"
  s.version = "1.2.0"

  s.authors = ["Sebastian Johnsson"]
  s.description = "Wrapper for Faraday with additional functionality"

  s.homepage = "http://github.com/Agiley/http_utilities"
  s.summary = "Wrapper for Faraday with additional functionality"
  
  s.add_dependency(%q<nokogiri>, [">= 1.6"])
  s.add_dependency(%q<mechanize>, [">= 2.7"])
  s.add_dependency(%q<net-ssh>, [">= 2.9"])
  
  s.add_development_dependency(%q<rails>, [">= 0"])
  s.add_development_dependency(%q<rspec>, [">= 0"])
  s.add_development_dependency(%q<sqlite3>, [">= 0"])
  s.add_development_dependency(%q<mysql2>, [">= 0"])
  s.add_development_dependency(%q<activerecord-import>, [">= 0"])
  
  # = MANIFEST =
 s.files = %w[
 Gemfile
 README
 Rakefile
 VERSION
 http_utilities.gemspec
 lib/generators/active_record/http_utilities_generator.rb
 lib/generators/active_record/templates/migration.rb
 lib/generators/active_record/templates/proxy.rb
 lib/generators/helpers/file_helper.rb
 lib/generators/helpers/orm_helpers.rb
 lib/generators/http_utilities/http_utilities_generator.rb
 lib/generators/templates/http_utilities.rb
 lib/generators/templates/user_agents.yml
 lib/http_utilities.rb
 lib/http_utilities/http/client.rb
 lib/http_utilities/http/logger.rb
 lib/http_utilities/http/mechanize/client.rb
 lib/http_utilities/http/proxy_support.rb
 lib/http_utilities/http/request.rb
 lib/http_utilities/http/response.rb
 lib/http_utilities/http/url.rb
 lib/http_utilities/http/user_agent.rb
 lib/http_utilities/jobs/resque/proxies/check_proxies_job.rb
 lib/http_utilities/jobs/resque/proxies/check_proxy_job.rb
 lib/http_utilities/jobs/sidekiq/proxies/check_proxies_job.rb
 lib/http_utilities/jobs/sidekiq/proxies/check_proxy_job.rb
 lib/http_utilities/proxies/mongo/proxy_module.rb
 lib/http_utilities/proxies/mysql/proxy_module.rb
 lib/http_utilities/proxies/proxy_checker.rb
 lib/http_utilities/proxies/proxy_seeder.rb
 lib/http_utilities/railtie.rb
 lib/tasks/http_utilities_tasks.rake
 spec/database.yml.example
 spec/http_utilities/client_spec.rb
 spec/http_utilities/mechanize_client_spec.rb
 spec/http_utilities/proxy_checker_spec.rb
 spec/http_utilities/proxy_seeder_spec.rb
 spec/http_utilities/proxy_spec.rb
 spec/models.rb
 spec/schema.rb
 spec/spec_helper.rb
 ]
 # = MANIFEST =
   
   s.test_files = s.files.select { |path| path =~ %r{^spec/*/.+\.rb} }
end 