module HttpUtilities
  module Http
    class Response
      include HttpUtilities::Http::Format
      include HttpUtilities::Http::Logger
      
      attr_accessor :body, :parsed_body, :page_object, :format, :request
      
      def initialize(body = nil, request = nil, options = {})
        self.body         =   body
        self.request      =   request
        
        self.parsed_body  =   nil
        
        self.format       =   options.delete(:format) { |e| nil }
        
        self.convert_with_iconv
        self.parse_response
      end

      def convert_with_iconv
        if (self.body && self.body.present?)
          begin
            ic          =   Iconv.new('UTF-8//IGNORE', 'UTF-8')
            self.body   =   ic.iconv(self.body + ' ')[0..-2]
          rescue Exception => e
            log(:error, "[HttpUtilities::Http::Format] - Failed to convert response with iconv. Error: #{e.class.name} - #{e.message}.")
          end
          
          self.body = self.body.force_encoding('utf-8')
        end
      end

      def parse_response
        self.send("as_#{self.format}".to_sym) if (self.body && self.body.present? && self.format)
      end
            
    end
  end
end