require File.expand_path('../../spec_helper', __FILE__)

describe HttpUtilities::Http::Mechanize::Client do

  describe "when modules have been included" do
    before(:each) do
      @client = HttpUtilities::Http::Mechanize::Client.new
    end

    it "should respond to a proxy module method" do
      @client.should respond_to(:set_proxy_options)
    end

    it "should respond to a user agent module method" do
      @client.should respond_to(:set_user_agents)
    end

    it "should respond to a request module method" do
      @client.should respond_to(:generate_request_url)
    end

    it "should respond to a format module method" do
      @client.should respond_to(:as_html)
    end
  end

  describe "when initialized" do
    before(:each) do
      @client = HttpUtilities::Http::Mechanize::Client.new
    end

    it "should have assigned user agents" do
      @client.user_agents.should_not be_nil
      @client.user_agents.size.should > 0
    end

    it "should return a randomized user agent" do
      @client.randomize_user_agent_string.should_not be_nil
      @client.randomize_user_agent_string.length > 0
    end

    it "should submit a google search query successfully" do
      response = @client.set_form_and_submit("http://www.google.com/webhp", {:name => "f"}, :first, {:q => {:type => :input, :value => "Ruby on Rails"}})
      response.parser.content.should =~ /result(s)?/i
    end

    it "should submit a google search query using proxy successfully" do
      form_elements   =   {:q => {:type => :input, :value => "Ruby on Rails"}}
      options         =   {:use_proxy => true, :proxy => "127.0.0.1:80", :response_only => false}

      result      =   @client.set_form_and_submit("http://www.google.com/webhp", {:name => "f"}, :first, form_elements, options)
      response    =   result[:response]
      agent       =   result[:agent]

      agent.proxy_uri.hostname.should == "127.0.0.1"
      agent.proxy_uri.port.should == 80

      #Using 127.0.0.1:80 as a proxy will raise errors and thus return an empty response...
      response.should be_nil
    end
  end

end

