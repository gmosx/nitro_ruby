require "liquid"

module LiquidMethods
    
    def to_liquid
        self
    end
    
    def invoke_drop(method)      
        if self.class.public_instance_methods.include?(method)
            return send(method)
        else
            return nil
        end
    end
    
    def has_key?(name)
        true
    end

    alias :[] :invoke_drop

end
