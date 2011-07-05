require File.expand_path('../../spec_helper', __FILE__)

describe Proxy do
  
  before(:each) do
    clean_database!
    @proxy = Proxy.new
  end

  describe "when initialized" do
    it "should respond to module methods" do
      @proxy.should respond_to(:proxy_address)
    end
  end
  
end