require 'generators/helpers/file_helper'

module HttpUtilities
  module Generators
    class HttpUtilitiesGenerator < Rails::Generators::Base
      include HttpUtilities::Generators::FileHelper
      namespace "http_utilities"
      source_root File.expand_path("../../templates", __FILE__)
      
      class_option :orm
      hook_for :orm
            
      desc "Copies an initializer, a .yml-file containing user-agents as well as a proxy model."
      
      #def copy_initializer
      #  template "http_utilities.rb", "config/initializers/http_utilities.rb" unless file_exists?("config/initializers/http_utilities.rb")
      #end
      
    end
  end
end