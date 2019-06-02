require "stdx/string/html_transforms"

describe "String#html_strip" do

    it "removes html markup" do
    	str = %{test<b onmouseover="alert('xss')"}.html_strip
    	str.should == "test&lt;b onmouseover=&quot;alert('xss')&quot;"
    end

end

describe "String#nofollowify" do

    it 'adds rel="nofollow" to links' do
    	str = 'hello <a href="gmosx.com">Gmosx</a>'.nofollowify
    	str.should == 'hello <a href="gmosx.com" rel="nofollow">Gmosx</a>'
    end

end

