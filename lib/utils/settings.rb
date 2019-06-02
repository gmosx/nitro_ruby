
require "xmlsimple"

require "stdx/object/metaclass"
require "stdx/kernel/constant"
require "stdx/string/convert"

class Module 
    
    # Introduce a new setting for this class.
    #
    # Example:
    #
    #   class Application
    #       setting :path, :value => "/"
    #       setting :name, :value => "appname"
    #   end
    #
    #   Application::path # => "/"
    #   Application.path # => "/"
    #
    # The usage of the :: notation is prefered as it better denotes the setting
    # variable.
    
    def setting(name, options = {}) 
        metaclass.send(:attr_accessor, name)
        instance_variable_set("@#{name}", options[:value])
    end

end

class Settings

class << self
    
    attr_accessor :hash

    # Parse settings from an XML string.
    
    def parse_xml(xml)
        return XmlSimple.xml_in(
            xml,
            "KeepRoot" => false, "ForceArray" => false, "KeyToSymbol" => true
        )
    end
    
    # Parse settings from an XML file.

    def load_xml(path)
        parse_xml(File.read(path))
    rescue Errno::ENOENT => ex
        error "Settings file not found"
        return nil
    end

    # Configure from xml settings.
    
    def configure_xml(path)
        settings = load_xml(path)
        update(settings)
        return @hash
    end
    
    # Try to update settings for classes as described by the input hash that
    # contains settings data.
    #
    # You can also use nested.my_module or Nested.MyModule to configure Nested::MyModule
    #--
    # TODO: 
    # - implement typecasting from default values.
    # - initialize from xml/json.
    #++
        
    def update(hash)
        @hash ? @hash.update(hash) : @hash = hash
        hash.each { |k, v|
            begin
                # k = k.to_s.gsub(/\./, "::")
                k = k.to_s.to_const_string
                if klass = Kernel.constant(k) and klass.is_a?(Class) and v.is_a?(Hash)
                    v.each { |vk, vv|
                        if klass.respond_to? vk
                            klass.instance_variable_set("@#{vk}", vv)
                        end
                    }
                end
            rescue NameError => ex
                # drink it
            end
        }
    end
    
    #--
    # FIXME: improve key calculation.
    #++
    
    def configure(klass, key = klass.name.downcase.to_sym)
        return unless @hash
        
        @hash[key].each { |vk, vv|
            if klass.respond_to? vk
                klass.instance_variable_set("@#{vk}", vv)
            end
        }
    end    
    
end # self
    
end

