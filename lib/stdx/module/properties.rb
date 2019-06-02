require "stdx/object/metaclass"
require "stdx/object/trait"

# Properties are annotated object attributes. 

module Properties

    module ClassMethods
        # Define a property. 
        # Stores properties annotations in the :properties trait.
        
        def property(name, annotation = {})
            unless trait[:PROPERTIES][name]
                # create a new property
                attr_accessor(name)
                trait[:PROPERTIES][name] = annotation
            else
                # annotate an existing property
                trait[:PROPERTIES][name].update(annotation)
            end
        end
        alias_method :prop_accessor, :property

        # The names of all defined properties.
        
        def property_names
            trait[:PROPERTIES].keys
        end

        # All property annotations as a hash keyed by name.
                
        def property_annotations
            trait[:PROPERTIES]
        end
    end

    # Propagate Properties to subclasses.

    def self.included(base)
        base.metaclass.send(:include, ClassMethods)
        base.trait[:PROPERTIES] = {}

        base.module_eval do
            def self.inherited(subclass)
                subclass.send(:include, Properties)
                subclass.trait[:PROPERTIES] = self.trait[:PROPERTIES].merge(subclass.trait[:PROPERTIES])
                super
            end
        end
        
        super
    end

end

