
module Web

module Dispatcher

    # Select the appropriate resource and method from the uri.
    # Setup the request/response helper objects.
    
    def dispatch(env)
        request = Request.new(env)

        request.path_info.gsub!(/\/$/, "") # hack fix!!!

        path, ext = request.path_info.split(".")
        path, id = path.split("/*")
   
        if id
            request["id"] = id
            path << "/id"                
        end

        response = Response.new
        
        unless response.select_mime(request, ext)
            raise Forbidden.new("Access forbidden")
        end
        
        path << ".#{response.mime.extension}"

        unless resource_class = @dispatch_map[path]
            Object.send(:remove_const, :Resource) rescue nil
            resource_path = "#{Resource.root}#{path}.rb"

            begin
                require(resource_path)
                @dispatch_map[path] = resource_class = ::Resource
            rescue LoadError => ex
                unless File.exist?(resource_path)
                    if File.exist?("#{Template.root}#{path}")
                        @dispatch_map[path] = resource_class = Web::StaticResource
                    else
                        raise MethodNotFound.new(path) 
                    end
                else
                    raise # This is a deeper LoadError, raise it.
                end
            end
        end

        resource = resource_class.new(request, response, self, path)
        method = request.request_method.downcase
        
        return resource, method, response
    end

end

end
