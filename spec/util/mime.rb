require "spec/common"

require "util/mime"

describe "MIME types" do

    it "EXTENSION_TO_MIME returns MIME type information for the given extension" do
        MIME::EXTENSION_TO_MIME["html"].content_type.should == "text/html"
        MIME::EXTENSION_TO_MIME["atom"].convert_method.should == :to_atom
        MIME::EXTENSION_TO_MIME["atom"].extension.should == "atom"
    end

    it "CONTENT_TYPE_TO_MIME is generated from EXTENSION_TO_MIME" do
        MIME::EXTENSION_TO_MIME["html"].should == MIME::CONTENT_TYPE_TO_MIME["text/html"]
        MIME::EXTENSION_TO_MIME["atom"].should == MIME::CONTENT_TYPE_TO_MIME["application/xml"]
    end
    
end

