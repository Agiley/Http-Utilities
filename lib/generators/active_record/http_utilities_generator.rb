require 'rails/generators/active_record'
require 'generators/http_utilities/orm_helpers'

module ActiveRecord
  module Generators
    class HttpUtilitiesGenerator < ActiveRecord::Generators::Base
      
      include HttpUtilities::Generators::OrmHelpers
      source_root File.expand_path("../templates", __FILE__)
      
      def copy_proxy_migration
        migration_template "migration.rb", "db/migrate/create_proxies"
      end
      
      def copy_proxy_model
        template "proxy.rb", "app/models/proxy.rb" unless model_exists? && behavior == :invoke
      end

    end
  end
end
