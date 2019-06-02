require "stdx/object/metaclass"

# Add subclass tracking to a specific class.
# http://ola-bini.blogspot.com/2007/07/objectspace-to-have-or-not-to-have.html
#
# Examples:
#   DB::Managed.extend(SubclassTracking)
#   Web::Resource.extend(SubclassTracking)
#--
# FIXME: Module 'chaining' has problems
#++

module SubclassTracking

    def self.extended(klass)
        meta = klass.metaclass
        meth = klass.class == Class ? :inherited : :included
   
        meta.send(:attr_accessor, :subclasses)
        meta.send(:define_method, meth) { |c|
            klass.subclasses << c
            super
        }

        klass.subclasses = []
    end

end
