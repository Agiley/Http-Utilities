module HttpUtilities
  module Http
    module Post
      
      def post_and_retrieve_parsed_html(url, data, options = {})
        return as_html(post_and_retrieve_content(url, data, options))
      end

      def post_and_retrieve_parsed_xml(url, data, options = {})
        return as_xml(post_and_retrieve_content(url, data, options))
      end
      
      def post_and_retrieve_content(url, data, options = {})
        response = nil
        method = options[:method] || :net_http

        if (method.eql?(:net_http))
          response = post_and_retrieve_content_using_net_http(url, data, options)
        elsif (method.eql?(:curl))
          response = post_and_retrieve_content_using_curl(url, data, options)
        end
        
        return response
      end
      
    end
  end
end