# -*- encoding : utf-8 -*-
require 'nokogiri'

module HttpUtilities
  module Http
    module Format
      
      def as_html
        self.parsed_body = (self.body && self.body != "") ? Nokogiri::HTML(self.body, nil, "utf-8") : nil
      end

      def as_xml
        self.parsed_body = (self.body && self.body != "") ? Nokogiri::XML(self.body, nil, "utf-8") : nil
      end
      
      def as_multi_xml
        self.parsed_body = (self.body && self.body != "") ? MultiXml.parse(self.body) : nil
      end

      def as_json
        self.parsed_body = (self.body && self.body != "") ? self.body.to_json : nil
      end
      
    end
  end
end