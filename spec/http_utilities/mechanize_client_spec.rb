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
      response = @client.set_form_and_submit("http://www.google.com/webhp", {:name => "f"}, :first, {:q => {:type => :input, :value => "Ruby on Rails"}})
      response.page_object.parser.content.should =~ /result(s)?/i
    end

    it "should submit a google search query using proxy successfully" do
      form_elements   =   {:q => {:type => :input, :value => "Ruby on Rails"}}
      options         =   {:use_proxy => true, :proxy => "127.0.0.1:80", :response_only => false}

      response      =   @client.set_form_and_submit("http://www.google.com/webhp", {:name => "f"}, :first, form_elements, options)

      response.request.proxy[:host].should == "127.0.0.1"
      response.request.proxy[:port].should == 80

      #Using 127.0.0.1:80 as a proxy will raise errors and thus return an empty response...
      response.page_object.should be_nil
    end
  end

end