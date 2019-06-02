require "stdx/module/properties"

describe "Properties" do

    class Id
        include Properties
        prop_accessor :name
    end

    class User < Id
        prop_accessor :age
    end

    it "should propagade" do
        User.ancestors.should include(Properties)
        User.property_names.should include(:name, :age)
    end
         
end

