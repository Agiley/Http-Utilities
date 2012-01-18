module HttpUtilities
  module Http
    module Cookies

      def handle_cookies(response)
        cookies = nil

        if (response && response.is_a?(Net::HTTPResponse))
          cookie_fields = response.get_fields('Set-Cookie')
          
          if (cookie_fields && cookie_fields.any?)
            cookies = []
            cookie_fields.each do |cookie|
              filtered_cookie = cookie.split('; ').first
              cookies << filtered_cookie
            end
          end
        
        elsif (response && response.is_a?(HttpUtilities::Http::Response))
          cookies = (response.request && response.request.cookies) ? response.request.cookies : nil
        end

        return cookies
      end

      def format_cookies(cookies)
        cookie_string = ""
        cookies.each {|cookie| cookie_string += "#{cookie}; "}

        return cookie_string
      end

      def set_cookies(headers, cookies)
        if (cookies && cookies.any?)
          cookie_string     =   (cookies && cookies.is_a?(Array)) ? format_cookies(cookies) : nil

          if (cookie_string && cookie_string.present?)
            cookie_hash     =   {'cookie' => cookie_string}
            headers         =   (headers && !headers.empty?) ? headers.merge(cookie_hash) : cookie_hash
          end
        end

        return headers
      end

    end
  end
end

