require "spec/common"

require "util/atom"

describe "Atom" do

    class Article
        attr_accessor :id, :title, :uri, :updated, :summary
    end

    it "encodes compatible objects" do
        a = Article.new
        a.id = 1
        a.uri = "http://www.app.com"
        a.title = "hello"
        a.updated = Time.local(2000, "jan", 1, 20, 15, 1)
        a.summary = "the summary"
        
        Atom.encode(a).should == %{<entry>\n            <title>hello</title>\n            <link href=\"http://www.app.com\"/>\n            <id>1</id>\n            <updated>2000-01-01T20:15:01+02:00</updated>\n            <summary>the summary</summary>\n        </entry>}
    end
    
    it "encodes collections of objects into feeds" do
        list = []
        a = Article.new
        a.id = 1
        a.uri = "http://www.app.com"
        a.title = "hello1"
        a.updated = Time.local(2000, "jan", 1, 20, 15, 1)
        a.summary = "the summary1"
        list << a
        a = Article.new
        a.id = 1
        a.uri = "http://www.app.com"
        a.title = "hello2"
        a.updated = Time.local(2000, "jan", 1, 20, 15, 1)
        a.summary = "the summary2"
        list << a
        feed = Atom.encode_all(list)
        
        # TODO: add regexp tests!
    end

end
