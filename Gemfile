source "http://rubygems.org"

gem 'rails'
gem 'nokogiri'
gem 'mechanize'
gem "activerecord-import", ">= 0.2.0"
#gem 'activerecord-import', :git => 'git://github.com/Agiley/activerecord-import.git'

platforms :ruby do
  gem 'curb'
end

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