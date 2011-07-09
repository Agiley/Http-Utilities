module HttpUtilities
  module Generators
    class HttpUtilitiesGenerator < Rails::Generators::Base
      namespace "http_utilities"
      source_root File.expand_path("../../templates", __FILE__)
      
      class_option :orm
      hook_for :orm
            
      desc "Copies an initializer, a .yml-file containing user-agents as well as a proxy model."
      
      def copy_initializer
        template "http_utilities.rb", "config/initializers/http_utilities.rb" unless file_exists?("config/initializers/http_utilities.rb")
      end
      
      def copy_user_agents
        template "user_agents.yml", "config/http_utilities/user_agents.yml"
      end
      
      def copy_seed_folder
        copy_dir "seed_data", "db/seed_data"
      end
      
    end
  end
end