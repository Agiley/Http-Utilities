module HttpUtilities
  module Generators
    module FileHelper

      private

      def copy_dir(source, destination)
        root_dir=File.join(self.source_root, source)
        Dir[File.join(root_dir, "**/*")].each do |file|
          relative = file.gsub(/^#{root_dir}\//, '')
          copy_file file, File.join(Rails.root, destination, relative) if File.file?(file)
        end
      end

      def file_exists? path
        File.exists?(File.join(destination_root, path))
      end
      
    end
  end
end