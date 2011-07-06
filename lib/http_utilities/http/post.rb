module HttpUtilities
  module Http
    module Post
      
      def post_and_retrieve_content(url, data, options = {})
        response = nil

        method = options[:method] || :net_http

        if (method.eql?(:net_http))
          response = post_and_retrieve_content_using_net_http(url, options)
        elsif (method.eql?(:curl))
          response = post_and_retrieve_content_using_curl(url, options)
        end

        #puts "Raw response: #{response}\n\n"

        return response
      end

      def post_and_retrieve_parsed_html(url, data, options = {})
        response = post_and_retrieve_content(url, data, options)
        return (response && response.present?) ? Nokogiri::HTML(response, nil, "utf-8") : nil
      end

      def post_and_retrieve_parsed_xml(url, data, options = {})
        response = post_and_retrieve_content(url, data, options)
        return (response && response.present?) ? Nokogiri::XML(response, nil, "utf-8") : nil
      end
      
    end
  end
end