module HttpUtilities
  module Generators
    class HttpUtilitiesGenerator < Rails::Generators::NamedBase
      namespace "http_utilities"
      source_root File.expand_path("../templates", __FILE__)

      desc "Generates a proxy model and migration file, as well as generating a configuration file."

      hook_for :orm
    end
  end
end