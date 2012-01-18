source "http://rubygems.org"

gem 'rails'
gem 'nokogiri'
gem 'mechanize'
gem "activerecord-import"

gem 'curb' if defined?(JRUBY_VERSION)

group :development, :test do
  gem 'jeweler'
  gem 'rspec'
  gem 'rcov'
  gem 'sqlite3'
  gem "generator_spec"
  
  platforms :ruby do
    gem 'mysql2', '0.2.7'
  end
end