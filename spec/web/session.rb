require "liquid"

require "web/session"

describe "Session" do

    it "keeps track of dirty status" do
        s = Web::Session.new
        s["test"] = "hello"
        s.dirty?.should == true
    end
    
    it "can be packed" do
        s = Web::Session.new
        s["test"] = "hello"
        s["invalid"] = nil
        s.pack!
        s.dirty?.should == nil
        s.size.should == 1
    end
   
    it "gets serialized and deserialized" do
        s = Web::Session.new
        s["test"] = "hello"
        s["invalid"] = nil
        data = Web::Session.send(:encode, s)
        sd = Web::Session.send(:decode, data)
        sd["test"].should == "hello"
        sd.include?("invalid").should == false
        sd.size.should == 1
        
        s = Web::Session.new
        data = Web::Session.send(:encode, s)
        sd = Web::Session.send(:decode, data)
        sd.size.should == 0        
    end
    
end

describe "SessionManagement" do

    class Response
        attr_accessor :cookie
        
        def set_cookie(key, cookie)
            @cookie = true
        end
    end

    it "only saves dirty sessions" do
        s = Web::Session.new
        r = Response.new
   
        Web::Session.save(s, r)
        r.cookie.should_not == true
        
        s["key"] = "value"
        Web::Session.save(s, r)        
        r.cookie.should == true
    end
end

describe "session#flash" do

    class MockRequestResponse
        attr_accessor :cookies
        
        def initialize
            @cookies = {}
        end
        
        def set_cookie(key, cookie)
            @cookies[key] = cookie[:value]
        end
    end
    
    it "keeps variables only for the next request" do
        mock = MockRequestResponse.new
        s = Web::Session.new
        s.flash "msg", "hello world"
        Web::Session.save(s, mock)
        s.instance_variable_get("@flash").should == nil
        s = Web::Session.load(mock)
        s.flash("msg").should == "hello world"
        Web::Session.save(s, mock)
        s = Web::Session.load(mock)
        s.flash("msg").should == nil
        s["FLASH"].should == nil
    end
    
    it "marks session as dirty when set" do
        s = Web::Session.new
        s.flash "msg", "hello world"
        s.dirty?.should == true
        s.pack! # emulate flash hash already created case.
        s.flash "more", "flash"
        s.dirty?.should == true
    end
        
end
