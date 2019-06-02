require "lib/util/settings"

module Nested
   
    class Demo
        setting :path, :value => "/nested"
    end
    
end

describe "Setting" do

    class Test
        setting :path, :value => "/hello"
    end

    it "is initialized" do
        Test.path.should == "/hello"
    end
    
    it "can be overriden" do
        Test.instance_variable_set("@path", "/changed")
        Test.path.should == "/changed"
    end
    
end

describe "Settings" do

    class Test
        setting :path, :value => "/hello"
        setting :age, :value => 2
    end

    class ConstantTest
        setting :PATH, :value => "/constant"
        setting :KEY, :value => "secret"
    end

    it "updates settings for classes" do
        settings = {
            :Test => {
                :path => "/conf",
                :age => 33,
                :none => "invalid"
            },
            :Invalid => {
            }
        }
        Settings.update(settings)
        Test.path.should == "/conf"
        Test::path.should == "/conf"
        Test.age.should == 33
        Test.instance_variable_get("@none").should == nil
    end        

    it "updates settings for nested classes/modules" do
        settings = {
            "Nested.Demo" => {
                :path => "/updated"
            }
        }
        Settings.update(settings)
        Nested::Demo.path.should == "/updated"

        settings = {
            "Nested::Demo" => {
                :path => "/onemoretime"
            }
        }
        Settings.update(settings)
        Nested::Demo.path.should == "/onemoretime"

        settings = {
            "nested.demo" => {
                :path => "/elegant?"
            }
        }
        Settings.update(settings)
        Nested::Demo.path.should == "/elegant?"
    end
        
    it "can look like constants" do
#       ConstantTest::KEY.should == "secret" => DOESN'T WORK :(
        ConstantTest.PATH.should == "/constant"
    end

   it "configures classes" do
        settings = {
            :test => {
                :path => "/conf",
                :age => 33,
                :none => "invalid"
            }
        }
        Settings.update(settings)
        Settings.configure(Test)
        Test.path.should == "/conf"
        Test::path.should == "/conf"
        Test.age.should == 33
        Test.instance_variable_get("@none").should == nil
    end        
 

end
