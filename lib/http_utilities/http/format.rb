# -*- encoding : utf-8 -*-
require 'nokogiri'

module HttpUtilities
  module Http
    module Format
      
      def as_html
        self.parsed_body = (self.body && self.body.present?) ? Nokogiri::HTML(self.body, nil, "utf-8") : nil
      end

      def as_xml
        self.parsed_body = (self.body && self.body.present?) ? Nokogiri::XML(self.body, nil, "utf-8") : nil
      end

      def as_json
        self.parsed_body = (self.body && self.body.present?) ? self.body.to_json : nil
      end
      
    end
  end
end