source "http://rubygems.org"

gem 'rails'

gem "nokogiri", ">= 1.5.5"
gem "mechanize", ">= 2.5"
gem "multi_xml", ">= 0.5"

gem "activerecord-import", :require => false

platforms :ruby do
  gem 'curb'
end

group :development, :test do
  gem 'jeweler'
  gem 'rspec'
  gem 'sqlite3'
  
  platforms :ruby do
    gem "mysql2", ">= 0.3.11"
  end
end