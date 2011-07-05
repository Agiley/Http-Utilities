module HttpUtilities
  module Generators
    class HttpUtilitiesGenerator < Rails::Generators::Base
      #namespace "http_utilities"
      source_root File.expand_path("../../templates", __FILE__)
      
      #class_option :orm
      hook_for :orm
      
      desc "Creates a HttpUtilities-initializer."
      def copy_initializer
        template "http_utilities.rb", "config/initializers/http_utilities.rb"
      end
      
      desc "Copies User Agents"
      def copy_user_agents
        template "user_agents.yml", "config/http_utilities/user_agents.yml"
      end
      
    end
  end
end