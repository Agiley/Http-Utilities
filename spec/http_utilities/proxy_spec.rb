require File.expand_path('../../spec_helper', __FILE__)

describe Proxy do

  describe "when initialized" do
    before(:each) do
      clean_database!
      @proxy = Proxy.new
    end
    
    it "should respond to proxy address module instance method" do
      @proxy.should respond_to(:proxy_address)
    end
    
    it "should correctly return a formatted proxy address" do
      @proxy.host = "127.0.0.1"
      @proxy.port = 80
      
      @proxy.proxy_address.should == "127.0.0.1:80"
      @proxy.proxy_address(include_http = true).should == "http://127.0.0.1:80"
    end
  end
  
  describe "in a class context" do
    it "should respond to get random proxy module class method" do
      Proxy.should respond_to(:get_random_proxy)
    end
    
    it "should respond to format proxy address module class method" do
      Proxy.should respond_to(:format_proxy_address)
    end
    
    it "should respond to format proxy credentials module class method" do
      Proxy.should respond_to(:format_proxy_credentials)
    end
    
    it "should respond to should_be_checked-scope" do
      Proxy.should respond_to(:should_be_checked)
    end
  end
  
  describe "when fetching proxies" do
    before(:each) do
      clean_database!
      data = {:host => "127.0.0.1", :port => 80, :protocol => 'http', :proxy_type => 'public', :category => 'L1'}
      
      #Http Proxies
      Proxy.create(data)
      Proxy.create(data.merge!({:port => 81, :proxy_type => 'shared'}))
      Proxy.create(data.merge!({:port => 82, :proxy_type => 'private'}))
      
      #Socks Proxies
      Proxy.create(data.merge!({:port => 83, :protocol => 'socks', :proxy_type => 'public'}))
      Proxy.create(data.merge!({:port => 84, :protocol => 'socks', :proxy_type => 'shared'}))
      Proxy.create(data.merge!({:port => 85, :protocol => 'socks', :proxy_type => 'private'}))
    end
    
    it "should return proxies that should be checked (using default parameters)" do
      proxies = Proxy.should_be_checked
      proxies.should_not be_nil
      proxies.size.should == 6
    end
    
    [:http, :socks].each do |protocol|
      it "should return #{protocol.to_s} proxies that should be checked" do
        proxies = Proxy.should_be_checked(protocol)
        proxies.should_not be_nil
        proxies.size.should == 3
      end
      
      [:public, :shared, :private].each do |proxy_type|
        it "should return #{proxy_type.to_s} #{protocol.to_s} proxies that should be checked" do
          proxies = Proxy.should_be_checked(protocol, proxy_type)
          proxies.should_not be_nil
          proxies.size.should == 1
        end
      end
    end

  end
  
end