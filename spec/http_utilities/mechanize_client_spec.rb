require File.expand_path('../../spec_helper', __FILE__)

describe HttpUtilities::Http::Mechanize::Client do

  describe "when modules have been included" do
    before(:each) do
      @client     =   HttpUtilities::Http::Mechanize::Client.new
      @request    =   HttpUtilities::Http::Request.new
    end

    it "should respond to a user agent module method" do
      @request.should respond_to(:user_agent)
    end

    it "should respond to a request module method" do
      @client.should respond_to(:generate_request_url)
    end
  end

  describe "when initialized" do
    before(:each) do
      @client     =   HttpUtilities::Http::Mechanize::Client.new
      @request    =   HttpUtilities::Http::Request.new
    end

    it "should have assigned user agents" do
      @request.user_agent.should_not be_nil
    end

    it "should submit a google search query successfully" do
      #mock this later on...
      response = @client.set_form_and_submit("http://www.google.com/webhp", {:name => "f"}, :first, {:q => {:type => :input, :value => "Ruby on Rails"}})
      response.page.parser.should_not be_nil
    end
  end

end