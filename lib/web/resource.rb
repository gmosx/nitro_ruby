require "stdx/file/write"

require "utils/template"

require "web/session"
require "web/mixins/caching/output"

module Web

# Valid HTTP methods.

HTTP_METHODS = ["get", "put", "post", "head", "delete"]

# Base class for REST resources. 
# Also encapsulates the request environment.

class Resource

    setting :root, :value => "root"

    attr_accessor :request, :response, :application, :scope

    def initialize(request, response, application, template_path)
        @request = request
        @response = response
        @application = application
        @template_path = template_path
        init_scope
    end

    include SessionManagement    

    @@template_cache = {}

    def self.template_cache
        @@template_cache
    end
    
    # Handles a HTTP request.
    
    def handle(method)
        raise Forbidden.new("Forbidden HTTP method") unless HTTP_METHODS.include? method
        send(method)
        render unless @rendered
        write_output_to_fs(@response.body) if @scope["CACHE_OUTPUT"]        
    end

    # Handle a GET HTTP request.
    
    def get
    end

    # Handle a PUT HTTP request.    
    
    def put
    end
    
    # Handle a POST HTTP request.    
        
    def post
    end

    # Handle a HEAD HTTP request.    
    
    def head
    end

    # Handle a DELETE HTTP request.    
    
    def delete
    end    

private

    # Override to perform scope initialization at the app level or resource
    # level.
    
    def init_scope
        @scope = {}
    end    

    # Perform an HTTP redirect.
    
    def redirect(uri = @request.referer)
        raise SeeOther.new(uri)
    end
    alias_method :redirect!, :redirect

    # Render the template.
    
    def render
        t = Template.get(@template_path, @scope)
        @response.write(t.render(@scope))
        @rendered = true        
    rescue IOError => ioe 
        raise TemplateNotFound.new(ioe.message)
    end

    # Print to the response body.
    
    def print(str)
        if @buffer
            @buffer = str
        else
            @response.write(str)
        end
        @rendered = true
    end
    
    # Start buffering the response.
    
    def open_buffer
        @buffer = true
    end
    
    # End buffering.
    
    def close_buffer
        b = @buffer
        @buffer = nil
        return b
    end

end

# A HTML resource. The most common dynamic resource.

class HTMLResource < Resource

private

    def render
        t = Template.get(@scope.fetch("TEMPLATE", @template_path), @scope)
        @response.write(t.render(@scope))
        @rendered = true        
    rescue IOError => ioe 
        raise TemplateNotFound.new(ioe.message)
    end
            
end

# Perform an action (typically post) and redirect. Generates no output.

class ActionResource < Resource

    def handle(method)
        raise Forbidden.new("Forbidden HTTP method") unless HTTP_METHODS.include? method
        send(method)
        redirect
    end
    
end

# Perform an Ajax action.

class AjaxResource < Resource

    def handle(method)
        if request.xhr?
		    raise Forbidden.new("Forbidden HTTP method") unless HTTP_METHODS.include? method
		    send(method)
		else
			raise Forbidden.new("This resource is only callable by Ajax")
	    end
    end

end

# A static resource. Immediately cached into the public directory.
#--
# TODO: separate Resouce classes for .js, .css etc.
#++

class StaticResource < Resource

    include Caching
    
    def handle(method)
        get()
        t = Template.get(@template_path, @scope)
        @response.write(t.render(@scope))

        unless $DBG
            write_output_to_fs(@response.body)
            compress!
        end
    rescue IOError => ioe 
        raise TemplateNotFound.new(ioe.message)
    end
    
    def compress!
        case File.extname(@template_path)
        when ".css", ".js"
            path = "public#{@template_path}"
            system("java -jar etc/yuicompressor-2.3.6.jar #{path} -o #{path}")
        end
    end
    
end

end

