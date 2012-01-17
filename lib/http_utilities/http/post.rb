module HttpUtilities
  module Http
    module Post

      def post_and_retrieve_parsed_html(url, data, options = {})
        options.merge!({:force_encoding => true, :format => :html})
        return post_and_retrieve_content(url, data, options)
      end

      def post_and_retrieve_parsed_xml(url, data, options = {})
        options.merge!({:force_encoding => true, :format => :xml})
        return post_and_retrieve_content(url, data, options)
      end

      def post_and_retrieve_content(url, data, options = {})
        response        =   nil
        method          =   options[:method] || :net_http
        response_only   =   options.delete(:response_only) { |e| true }

        if (method.eql?(:net_http))
          result = post_and_retrieve_content_using_net_http(url, data, options)
        elsif (method.eql?(:curl))
          result = post_and_retrieve_content_using_curl(url, data, options)
        end

        result    =   parse_response(result, options[:format])
        result    =   (response_only) ? result[:response] : result

        return result
      end

    end
  end
end

