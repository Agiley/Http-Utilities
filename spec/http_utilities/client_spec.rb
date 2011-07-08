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
    
    it "should respond to a format module method" do
      @client.should respond_to(:as_html)
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
    
    it "should return a properly formatted request url using supplied parameters" do
      params = {:url => "http://www.google.com", :q => "ruby on rails", :start => 0}
      @client.generate_request_url(params).should == "http://www.google.com?q=ruby%20on%20rails&start=0"
    end
    
    describe "when retrieving content using Net::Http" do
      it "should fetch Google results as unparsed HTML" do
        params = {:url => "http://www.google.com", :q => "ruby on rails", :start => 0}
        response = @client.retrieve_raw_content(@client.generate_request_url(params), {:method => :net_http})
        response.should be_a(String)
      end

      it "should fetch Google results as a Nokogiri::HTML::Document" do
        params = {:url => "http://www.google.com", :q => "ruby on rails", :start => 0}
        response = @client.retrieve_parsed_html(@client.generate_request_url(params), {:method => :net_http})
        response.should be_a(Nokogiri::HTML::Document)
      end

      it "should fetch Google Weather data a Nokogiri::XML::Document" do
        params = {:url => "http://www.google.com/ig/api", :weather => 90120}
        response = @client.retrieve_parsed_xml(@client.generate_request_url(params), {:method => :net_http})
        response.should be_a(Nokogiri::XML::Document)
      end
    end
    
    describe "when retrieving content using a proxy" do
      it "should have the proxy instance variable properly set" do
        options = {:method => :net_http, :proxy => "127.0.0.1:80"}
        params = {:url => "http://www.google.com", :q => "ruby on rails", :start => 0}

        @client.retrieve_parsed_html(@client.generate_request_url(params), options)
        
        @client.proxy.should_not be_nil
        @client.proxy[:host].should == '127.0.0.1'
        @client.proxy[:port].should == 80
      end
    end
    
    describe "when persisting cookies" do
      it "should have the cookie instance variable properly set" do
        options = {:method => :net_http, :use_cookies => true, :save_cookies => true}
        params = {:url => "http://www.google.com", :q => "ruby on rails", :start => 0}

        @client.retrieve_parsed_html(@client.generate_request_url(params), options)
        
        @client.cookies.should_not be_nil
      end
    end
    
    describe "when posting content" do
      before(:each) do
        @trackback_url    =   "http://techcrunch.com/wp-trackback.php?p=314942"
        @post_data        =   {
          :url        =>  "http://www.google.com",
          :blog_name  =>  "Testing",
          :title      =>  "Title",
          :excerpt    =>  "Testing..."
        }
      end
      
      if (!defined?(JRUBY_VERSION))
        it "should send a trackback to a TechCrunch post using Curb and return the response as a Nokogiri::XML::Document" do
          options = {:method => :curl}

          response = @client.post_and_retrieve_parsed_xml(@trackback_url, @post_data, options)
          response.should be_a(Nokogiri::XML::Document)
        end
      end
      
      it "should send a trackback to a TechCrunch post using Net::Http and return the response as a Nokogiri::XML::Document" do
        options = {:method => :net_http}

        response = @client.post_and_retrieve_parsed_xml(@trackback_url, @post_data, options)
        response.should be_a(Nokogiri::XML::Document)
      end
    end
    
  end
    
end