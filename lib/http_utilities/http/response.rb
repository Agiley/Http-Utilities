module HttpUtilities
  module Http
    class Response
      include HttpUtilities::Http::Format
      include HttpUtilities::Http::Logger

      attr_accessor :body, :parsed_body, :page, :format, :request, :force_encoding

      def initialize(body = nil, request = nil, options = {})
        options               =   options.clone()

        self.body             =   body
        self.request          =   request

        self.parsed_body      =   nil

        self.format           =   options.delete(:format) { |e| nil }
        self.force_encoding   =   options.delete(:force_encoding) { |e| true }

        encode if (self.force_encoding)
        parse_response
      end

      def encode
        if (self.body)
          begin
            self.body = self.body.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "").force_encoding('UTF-8')
          rescue Exception => e
            log(:error, "[HttpUtilities::Http::Format] - Failed to convert response with String#encode. Error: #{e.class.name}. Message: #{e.message}.")
          end
        end
      end

      def parse_response
        self.send("as_#{self.format}".to_sym) if (self.body && self.format)
      end

      def set_page(page)
        self.page = page

        if (page && page.parser)
          self.body         =   page.parser.content
          self.parsed_body  =   page.parser
        end
      end

    end
  end
end

