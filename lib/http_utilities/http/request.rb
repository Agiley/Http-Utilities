module HttpUtilities
  module Http
    class Request
      include HttpUtilities::Http::Logger
      include HttpUtilities::Http::ProxySupport
      include HttpUtilities::Http::UserAgent
      
      attr_accessor :interface, :proxy, :user_agent
      
      def initialize(interface: nil, proxy: nil, options: {})
        self.interface  =   interface
        self.proxy      =   proxy
        
        self.set_user_agent(device: options.fetch(:user_agent_device, :desktop))
      end
            
    end
  end
end
