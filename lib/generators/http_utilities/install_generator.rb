module HttpUtilities
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a HttpUtilities-initializer."
      class_option :orm

      def copy_initializer
        template "http_utilities.rb", "config/initializers/http_utilities.rb"
      end
      
      def copy_user_agents
        template "user_agents.yml", "config/http_utilities/user_agents.yml"
      end
      
    end
  end
end