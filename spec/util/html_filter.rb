require "util/html_filter"

describe "HTMLFilter" do

    it "handles base cases" do
        "".html_filter.should == ""
        "hello".html_filter.should == "hello"
    end

    it "fixes quotes" do
        '<img src="foo.jpg />'.html_filter.should == '<img src="foo.jpg" />'
    end

    it "adds or fixes end slashes" do
        "<img>".html_filter.should == "<img />"
        "<img/>".html_filter.should == "<img />"
    end

    it "strips empty/invalid tags" do
        "<b/></b>".html_filter.should == ""
        "<>".html_filter.should == ""
        "</b><b>".html_filter.should == ""
    end

    it "rebalances tags" do
        "<<b>hello</b>".html_filter.should == "<b>hello</b>"
        "<b>>hello</b>".html_filter.should == "<b>hello</b>"
        "<b>hello<</b>".html_filter.should == "<b>hello</b>"
        "<b>hello</b>>".html_filter.should == "<b>hello</b>"
    end

    it "completes tags" do
        "hello<b>".html_filter.should == "hello"
        "<b>hello".html_filter.should == "<b>hello</b>"
        "hello<b>world".html_filter.should == "hello<b>world</b>"
        "hello</b>".html_filter.should == "hello"
        "hello<b/>".html_filter.should == "hello"
        "hello<b/>world".html_filter.should == "hello<b>world</b>"
        "<b><b><b>hello".html_filter.should == "<b><b><b>hello</b></b></b>"
    end

    it "filters non-allowed tags" do
        "<table><tr><td>hello</td></tr></table>".html_filter.should == "hello"
    end

    it "filters non-allowed attributes" do
        %{<img onclick="alert('hello')" src="hi.png" />}.html_filter.should == '<img src="hi.png" />'
    end
    
end


