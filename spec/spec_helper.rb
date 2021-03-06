$LOAD_PATH << "." unless $LOAD_PATH.include?(".")

begin
  require "rubygems"
  require "bundler"

  if Gem::Version.new(Bundler::VERSION) <= Gem::Version.new("0.9.5")
    raise RuntimeError, "Your bundler version is too old." +
     "Run `gem install bundler` to upgrade."
  end

  # Set up load paths for all bundled gems
  Bundler.setup
rescue Bundler::GemNotFound
  raise RuntimeError, "Bundler couldn't find some gems." +
    "Did you run \`bundlee install\`?"
end

require "active_record"
require "logger"
Bundler.require

require File.expand_path('../../lib/http_utilities', __FILE__)

ENV['DB'] ||= 'sqlite3'

database_yml = File.expand_path('../database.yml', __FILE__)
if File.exists?(database_yml)
  active_record_configuration = YAML.load_file(database_yml)[ENV['DB']]
  
  ActiveRecord::Base.establish_connection(active_record_configuration)
  ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))
  
  ActiveRecord::Migration.verbose = false
  load(File.dirname(__FILE__) + '/schema.rb')
  load(File.dirname(__FILE__) + '/models.rb')
else
  raise "Please create #{database_yml} first to configure your database. Take a look at: #{database_yml}.example"
end

def clean_database!
  models = [Proxy]
  models.each do |model|
    ActiveRecord::Base.connection.execute "DELETE FROM #{model.table_name}"
  end
end

clean_database!