module HttpUtilities
  module Generators
    class HttpUtilitiesGenerator < Rails::Generators::Base
      namespace "http_utilities"
      source_root File.expand_path("../../templates", __FILE__)
      hook_for :orm
    end
  end
end