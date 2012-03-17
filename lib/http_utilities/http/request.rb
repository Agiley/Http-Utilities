module HttpUtilities
  module Http
    class Request
      include HttpUtilities::Http::Proxy
      include HttpUtilities::Http::UserAgent
      
      attr_accessor :interface, :proxy, :cookies, :user_agent
      
      def initialize(interface = nil, proxy = {}, cookies = [])
        self.interface  =   interface
        self.proxy      =   proxy
        self.cookies    =   cookies
        
        self.set_user_agent
      end
            
    end
  end
end