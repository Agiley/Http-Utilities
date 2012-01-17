module HttpUtilities
  module Generators
    module OrmHelpers
      
      def model_exists?(model)
        File.exists?(File.join(destination_root, model_path(model)))
      end

      def model_path(model)
        @model_path ||= File.join("app", "models", "#{model}.rb")
      end
      
    end
  end
end