require 'open-uri'
require 'uri'

module HttpUtilities
  module Http
    module UserAgent
      
      def set_user_agents
        agents = YAML.load(File.read(File.join(Rails.root, "config/http_utilities", "user_agents.yml")))["user_agents"] rescue nil
        agents ||= YAML.load(File.read(File.join(File.dirname(__FILE__), "../../generators/templates/user_agents.yml")))["user_agents"] rescue nil
        self.user_agents = agents if (agents && agents.any?)
      end

      def randomize_user_agent_string
        user_agent = (self.user_agents && self.user_agents.any?) ? self.user_agents[rand(self.user_agents.size)] : ""
        return user_agent
      end
      
    end
  end
end