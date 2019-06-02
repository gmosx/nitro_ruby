require "db/managed"

describe "DB::Managed" do

    class Article
        include DB::Managed
        attr_accessor :id, :body
        attr_accessor :hits
        attr_reader :date
    end

    it "assign_with assigns attributes from a hash" do
        h = { "hits" => 2 }
        a = Article.new.assign_with(h)
        a.hits.should == 2
    end

    it "assign_with ignores values with no attribute writer" do
        h = { "hits" => 2, "date" => "now" }
        a = Article.new.assign_with(h)
        a.hits.should == 2
        a.date.should == nil
    end

    it "assign_with ignores dangerous attributes (id)" do
        h = { "id" => 2}
        a = Article.new.assign_with(h)
        a.id.should == nil
    end

end

describe "properties" do

    class SuperClass
        include DB::Managed
        property :name, :class => String
        property :hits, :class => Integer
    end
    
    class SubClass < SuperClass
        property :sub, :class => Integer
    end
    
    it "are propageted to subclasses" do
        SuperClass.property_names.should include(:name, :hits, :id)
        SubClass.property_names.should include(:name, :hits, :sub, :id)
    end
    
end
