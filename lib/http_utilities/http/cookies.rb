module HttpUtilities
  module Http
    module Cookies
      
      def handle_cookies(use_cookies, save_cookies, response)
        if (use_cookies && save_cookies && response && response.is_a?(Net::HTTPResponse))
          cookie_fields = response.get_fields('Set-Cookie')
          if (cookie_fields && cookie_fields.any?)
            self.mutex.synchronize do
              self.cookies = []

              cookie_fields.each do |cookie|
                filtered_cookie = cookie.split('; ').first
                self.cookies << filtered_cookie
              end
            end
          end
        end
      end
      
      def format_cookies(cookies)
        cookie_string = ""
        cookies.each {|cookie| cookie_string += "#{cookie}; "}

        return cookie_string
      end
      
    end
  end
end