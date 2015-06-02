module HttpUtilities
  module Http
    class Response
      include HttpUtilities::Http::Logger

      attr_accessor :body, :parsed_body, :page, :format, :request, :force_encoding

      def initialize(response = nil, request = nil, options = {})
        options               =   options.dup

        self.body             =   (response && response.body) ? response.body : nil
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
            self.body = self.body.force_encoding('UTF-8').encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "")
          rescue Exception => e
            log(:error, "[HttpUtilities::Http::Format] - Failed to convert response with String#encode. Error: #{e.class.name}. Message: #{e.message}.")
          end
        end
      end

      def parse_response
        self.send("as_#{self.format}".to_sym) if (self.body && self.format)
      end
      
      def as_html
        self.parsed_body = (self.body && self.body != "") ? Nokogiri::HTML(self.body.to_s.force_encoding("utf-8"), nil, "utf-8") : nil
      end

      def as_xml
        self.parsed_body = (self.body && self.body != "") ? Nokogiri::XML(self.body.to_s.force_encoding("utf-8"), nil, "utf-8") : nil
      end

      def as_json
        self.parsed_body = (self.body && self.body != "") ? self.body.to_s.force_encoding("utf-8").to_json : nil
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

