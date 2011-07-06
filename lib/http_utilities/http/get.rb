module HttpUtilities
  module Http
    module Get
      
      def retrieve_raw_content(url, options = {})
        response = retrieve_content_from_url(url, options)
        return response
      end

      def retrieve_raw_xml(url, options = {})
        response = retrieve_content_from_url(url, options)
        return response
      end

      def retrieve_parsed_xml(url, options = {})
        return as_xml(retrieve_content_from_url(url, options.merge!({:force_encoding => true})))
      end

      def retrieve_parsed_html(url, options = {})
        return as_html(retrieve_content_from_url(url, options.merge!({:force_encoding => true})))
      end

      def as_html(response)
        return (response && response.present?) ? Nokogiri::HTML(response, nil, "utf-8") : nil
      end

      def as_xml(response)
        return (response && response.present?) ? Nokogiri::XML(response, nil, "utf-8") : nil
      end
      
      def as_json(response)
        return (response && response.present?) ? response.to_json : nil
      end

      def retrieve_parsed_html_and_fallback_to_proxies(url, options = {})
        response = retrieve_raw_content_and_fallback_to_proxies(url, options)
        response = as_html(response) if (response)
        return response
      end
      
      def retrieve_parsed_xml_and_fallback_to_proxies(url, options = {})
        response = retrieve_raw_content_and_fallback_to_proxies(url, options)
        response = as_xml(response) if (response)
        return response
      end

      def retrieve_raw_content_and_fallback_to_proxies(url, options = {})
        retries = 0
        max_retries = options.delete(:maximum_retrieval_retries) { |e| 5 }

        response = retrieve_content_from_url(url, options.merge!({:force_encoding => true}))

        while (!response && retries < max_retries) do
          options.merge!({:use_proxy => true})
          puts "Falling back to using proxies..."
          response = retrieve_content_from_url(url, options)
          retries += 1
        end

        return response
      end

      def retrieve_content_from_url(url, options = {})
        response = nil

        method = options[:method] || :net_http

        if (method.eql?(:open_uri))
          response = retrieve_open_uri_content(url, options)
        elsif (method.eql?(:net_http))
          response = retrieve_net_http_content(url, options)
        elsif (method.eql?(:curl))
          response = retrieve_curl_content(url, options)
        end

        #puts "Raw response: #{response}\n\n"

        return response
      end
      
    end
  end
end