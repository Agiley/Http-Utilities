module HttpUtilities
  module Http
    class Request
      include HttpUtilities::Http::Proxy
      attr_accessor :interface, :proxy, :cookies, :user_agent
      
      def initialize(interface = nil, proxy = {}, cookies = [])
        self.interface  =   interface
        self.proxy      =   proxy
        self.cookies    =   cookies
      end
            
    end
  end
end