require File.expand_path('../../spec_helper', __FILE__)

describe HttpUtilities::Http::Client do

  describe "when modules have been included" do
    before(:each) do
      @client = HttpUtilities::Http::Client.new
    end
    
    it "should respond to a net http module method" do
      @client.should respond_to(:post_and_retrieve_content_using_net_http)
    end
    
    it "should respond to a open uri module method" do
      @client.should respond_to(:retrieve_open_uri_content)
    end
    
    it "should respond to a curb module method" do
      @client.should respond_to(:post_and_retrieve_content_using_curl)
    end
    
    it "should respond to a proxy module method" do
      @client.should respond_to(:set_proxy_options)
    end
    
    it "should respond to a cookies module method" do
      @client.should respond_to(:handle_cookies)
    end
    
    it "should respond to a get module method" do
      @client.should respond_to(:retrieve_raw_content)
    end
    
    it "should respond to a post module method" do
      @client.should respond_to(:post_and_retrieve_content)
    end
  end
  
  describe "when initialized" do
    before(:each) do
      @client = HttpUtilities::Http::Client.new
    end
    
    it "should have assigned user agents" do
      @client.user_agents.should_not == nil
      @client.user_agents.size.should > 0
    end
    
    it "should return a randomized user agent" do
      @client.randomize_user_agent_string.should_not == nil
      @client.randomize_user_agent_string.length > 0
    end
  end
    
end