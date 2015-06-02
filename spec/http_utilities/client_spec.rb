require File.expand_path('../../spec_helper', __FILE__)

describe HttpUtilities::Http::Client do

  describe "when modules have been included" do
    before(:each) do
      @client     =   HttpUtilities::Http::Client.new
      @request    =   HttpUtilities::Http::Request.new
      @response   =   HttpUtilities::Http::Response.new
    end

    it "should respond to #get" do
      @client.should respond_to(:get)
    end

    it "should respond to #post" do
      @client.should respond_to(:post)
    end

    it "should respond to a proxy module method" do
      @request.should respond_to(:set_proxy_options)
    end

    it "should respond to a user agent module method" do
      @request.should respond_to(:user_agent)
    end

    it "should respond to a format module method" do
      @response.should respond_to(:as_html)
    end
  end

  describe "when initialized" do
    before(:each) do
      @client     =   HttpUtilities::Http::Client.new
      @request    =   HttpUtilities::Http::Request.new
    end

    it "should have assigned user agent" do
      @request.user_agent.should_not == nil
    end
  end
end