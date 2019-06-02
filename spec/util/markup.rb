require "util/markup"

describe "Markup##expand" do

    it "converts newlines to <br />" do
        str = %{
        This is some multiline text
        Do you like it?

        Of course you do!
        }
        Markup.expand(str).should == "<br />        This is some multiline text<br />        Do you like it?<br /><br />        Of course you do!<br />        "
    end
    
end


