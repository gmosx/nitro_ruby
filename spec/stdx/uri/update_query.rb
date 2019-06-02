require "stdx/uri/update_query"

describe "URI update_query" do

    it "works with no query string" do
        uri = URI.parse("http://www.app.com")
        uri.update_query("po" => 2)
        uri.to_s.should == "http://www.app.com?po=2"
    end

    it "works with query string" do
        uri = URI.parse("http://www.app.com?id=2")
        uri.update_query("po" => 2)
        uri.to_s.should == "http://www.app.com?id=2&po=2"
    end

    it "works with query string that contains the injected param" do
        uri = URI.parse("http://www.app.com?po=1")
        uri.update_query("po" => 2)
        uri.to_s.should == "http://www.app.com?po=2"
        uri = URI.parse("http://www.app.com?po=1&id=3")
        uri.update_query("po" => 2)
        uri.to_s.should == "http://www.app.com?po=2&id=3"
    end

    it "injects multiple params" do
        uri = URI.parse("http://www.app.com?id=2")
        uri.update_query("po" => 2, "ver" => 4)
        uri.to_s.should == "http://www.app.com?id=2&ver=4&po=2"
    end
         
end

describe "URI add_param" do

    it "works with no query string" do
        uri = URI.parse("http://www.app.com")
        uri.add_param("po", 2)
        uri.to_s.should == "http://www.app.com?po=2"
        
        URI.add_param("http://www.app.com", "po", 2).should == "http://www.app.com?po=2"
    end

    it "works with query string that contains the injected param" do
        uri = URI.parse("http://www.app.com?id=2&po=1")
        uri.add_param("po", 2)
        uri.to_s.should == "http://www.app.com?id=2&po=2"

        URI.add_param("http://www.app.com?id=2&po=1", "po", 2).should == "http://www.app.com?id=2&po=2"
    end
    
end
