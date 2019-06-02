require "spec/common"

require "web/response"

describe "Response#set_mime" do

    class MockRequest
        
        attr_accessor :path_info
        
        def initialize
            @path_info = "/fragment.inc.html"
        end
        
    end
    
    it "handles unknown mimes gracefully (returns nil)" do
        req = MockRequest.new
        res = Web::Response.new
        
        res.select_mime(req, "inc").should == nil
    end

end

