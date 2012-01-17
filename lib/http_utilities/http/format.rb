# -*- encoding : utf-8 -*-
require 'nokogiri'

module HttpUtilities
  module Http
    module Format
      
      def as_html(response)
        return (response && response.force_encoding('utf-8').present?) ? Nokogiri::HTML(response.force_encoding('utf-8'), nil, "utf-8") : nil
      end

      def as_xml(response)
        return (response && response.force_encoding('utf-8').present?) ? Nokogiri::XML(response.force_encoding('utf-8'), nil, "utf-8") : nil
      end
      
      def as_json(response)
        return (response && response.force_encoding('utf-8').present?) ? response.to_json : nil
      end
      
    end
  end
end