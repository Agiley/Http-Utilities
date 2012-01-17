module HttpUtilities
  module Http
    module Cookies

      def handle_cookies(use_cookies, save_cookies, response)
        cookies = nil

        if (use_cookies && save_cookies && response && response.is_a?(Net::HTTPResponse))
          cookie_fields = response.get_fields('Set-Cookie')
          if (cookie_fields && cookie_fields.any?)
            cookies = []

            cookie_fields.each do |cookie|
              filtered_cookie = cookie.split('; ').first
              cookies << filtered_cookie
            end
          end
        end

        return cookies
      end

      def format_cookies(cookies)
        cookie_string = ""
        cookies.each {|cookie| cookie_string += "#{cookie}; "}

        return cookie_string
      end

      def set_cookies(headers, cookies, use_cookies = false, request_cookies = nil, save_cookies = false)
        if (use_cookies || request_cookies)
          cookies         =   (request_cookies) ? request_cookies : cookies
          cookie_string   =   (cookies && cookies.is_a?(Array)) ? format_cookies(cookies) : nil
          
          if (cookie_string && cookie_string.present?)
            cookie_hash     =   {'cookie' => cookie_string}
            headers         =   (headers && !headers.empty?) ? headers.merge(cookie_hash) : cookie_hash
          end

        elsif (!use_cookies)
          cookies         =   nil
        end

        return [headers, cookies]
      end

    end
  end
end

