module HttpUtilities
  module Generators
    module FileHelper

      private

      def copy_dir(source, destination)
        root_dir=File.join(self.class.source_root, source)
        Dir[File.join(root_dir, "**/*")].each do |file|
          relative = file.gsub(/^#{root_dir}\//, '')
          copy_file file, File.join(Rails.root, destination, relative) if File.file?(file)
        end
      end
      
      def append_to_file(source, destination, prepend_with = "\n")
        source_file = File.join(self.class.source_root, source)
        destination_file = File.join(Rails.root, destination)
        
        if (File.exists?(source_file) && File.exists?(destination_file))
          source_data = []
          File.open(source_file, 'r') {|f| source_data = f.readlines("\n") }
          open(destination_file, 'a') { |dest_file|
            dest_file << prepend_with if (prepend_with)
            source_data.each { |line| dest_file.puts line }
          }
        end
      end

      def file_exists? path
        File.exists?(File.join(destination_root, path))
      end
      
    end
  end
end