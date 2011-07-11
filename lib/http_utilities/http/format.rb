require 'nokogiri'

module HttpUtilities
  module Http
    module Format
      
      def as_html(response)
        return (response && response.present?) ? Nokogiri::HTML(response, nil, "utf-8") : nil
      end

      def as_xml(response)
        return (response && response.present?) ? Nokogiri::XML(response, nil, "utf-8") : nil
      end
      
      def as_json(response)
        return (response && response.present?) ? response.to_json : nil
      end
      
    end
  end
end