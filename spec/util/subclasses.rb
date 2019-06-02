require "spec/common"

require "util/subclasses"

describe "SubclassTracking" do

    module M1
        extend SubclassTracking
    end
    
    module M2
        include M1
    end
    
    module M3
        include M1
    end

    class C1
        extend SubclassTracking
    end
    
    class C2 < C1
    end

    class C3 < C2
    end

    it "tracks Module subclasses (ie submodules)" do
        M1.subclasses.size.should == 2
        M1.subclasses.should include(M2)
        M1.subclasses.should include(M3)
    end

    it "tracks Class subclasses" do
        C1.subclasses.size.should == 2
        C1.subclasses.should include(C2)
        C1.subclasses.should include(C3)
    end
    
end

