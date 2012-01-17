require 'open-uri'
require 'uri'
require 'cgi'

module HttpUtilities
  module Http
    module Url
      
      def generate_request_url(params = {})
        params.symbolize_keys!
        url = params.delete(:url) { |e| "" }

        sorted_params = params.sort
        query_parts = []

        sorted_params.each do |param_row|
          param = encode_param(param_row.first)
          value = encode_param(param_row.last)
          query_parts << "#{param}=#{value}"
        end

        query = query_parts.join("&")
        request = "#{url}?#{query}"
        return request
      end
      
      def generate_request_params(params)
        sorted_params = params.sort
        query_parts = []

        sorted_params.each do |param_row|
          param = param_row.first
          value = param_row.last
          query_parts << "#{param}=#{value}"
        end

        query = query_parts.join("&")
        
        return query
      end

      def encode_param(param)
        return CGI.escape(param.to_s).to_s.gsub("+", "%20").gsub("%7E", "~") if (param && param.present?)
      end
      
    end
  end
end