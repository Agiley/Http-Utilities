source "http://rubygems.org"

gem 'rails'
gem 'nokogiri'
gem 'activerecord-import', :git => 'git://github.com/Agiley/activerecord-import.git'

platforms :ruby do
  gem 'curb'
end

group :development, :test do
  gem 'jeweler'
  gem 'rspec'
  gem 'rcov'
  gem 'sqlite3'
  
  platforms :ruby do
    gem 'mysql2'
  end
end