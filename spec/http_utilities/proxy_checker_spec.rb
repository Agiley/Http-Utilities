require File.expand_path('../../spec_helper', __FILE__)

describe HttpUtilities::Proxies::ProxyChecker do

  describe "when initialized" do
    before(:each) do
      @checker = HttpUtilities::Proxies::ProxyChecker.new
    end
        
    it "should not process proxies using jobs if Resque isn't available" do
      @checker.processing_method(nil).should == :iterate
      @checker.processing_method(:jobs).should == :iterate
    end
    
  end
end