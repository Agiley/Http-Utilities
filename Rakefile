begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "http_utilities"
    gemspec.summary = "Wrapper for common Http Libraries (Net:HTTP/Open URI/Curl)"
    gemspec.description = "Wrapper for common Http Libraries (Net:HTTP/Open URI/Curl)"
    gemspec.email = "sebastian@agiley.se"
    gemspec.homepage = "http://github.com/Agiley/http_utilities"
    gemspec.authors = ["Sebastian Johnsson"]
    gemspec.add_dependency 'rails'
    gemspec.add_development_dependency 'jeweler'
    gemspec.add_development_dependency 'rspec'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler -s http://gemcutter.org"
end

require 'bundler'
Bundler::GemHelper.install_tasks
