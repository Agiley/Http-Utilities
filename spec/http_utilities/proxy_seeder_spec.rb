require File.expand_path('../../spec_helper', __FILE__)

describe HttpUtilities::Proxies::ProxySeeder do

  describe "when initialized" do
    before(:each) do
      @seeder = HttpUtilities::Proxies::ProxySeeder.new
    end
        
    it "should parse proxies from text files" do
      proxy_data = @seeder.parse_proxies
      proxy_data.should_not be_nil
    end
    
    #Can only be tested on mysql, sqlite will fail with ConstraintExceptions (since it does not support on duplicate key update ...)
    if (ENV['DB'] == 'mysql')
      it "should import parsed proxies using activerecord-import" do
        @seeder.seed
        ::Proxy.count.should > 0
      end
    end
    
  end
end