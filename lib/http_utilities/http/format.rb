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

      def convert_with_iconv(response)
        if (response && response.present?)
          begin
            ic          =   Iconv.new('UTF-8//IGNORE', 'UTF-8')
            response    =   ic.iconv(response + ' ')[0..-2]
            response    =   response.force_encoding('utf-8')
          rescue Exception => e
            log(:error, "[HttpUtilities::Http::Format] - Failed to convert response with iconv. Error: #{e.class.name} - #{e.message}.")
          end
        end

        return response
      end

      def parse_response(result, format = nil)
        if (result && result.has_key?(:response) && result[:response])
          result[:response] = result[:response].force_encoding('utf-8')

          case format
            when :xml   then result[:response]    =   as_xml(result[:response])
            when :html  then result[:response]    =   as_html(result[:response])
            when :json  then result[:response]    =   as_json(result[:response])
          end
        end

        return result
      end

    end
  end
end

