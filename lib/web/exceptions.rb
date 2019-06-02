require "cgi"

#--
# TODO:
# - rename this file?
# - use @@status instead of STATUS?
# - use Exception (or other) postfix?
#++

module Web

class HTTPException < StandardError
    
    def http_status
        self.class::STATUS
    end

    def render(env)
        response = Response.new
        response.status = self.class::STATUS
        return response
    end

end

class Informational < HTTPException; end

    class Continue < Informational; STATUS = 100; end
    
    class SwitchingProtocols < Informational; STATUS = 101; end

class Redirection < HTTPException

    alias_method :uri, :message

    def render(env)
        response = Response.new
        response.status = self.class::STATUS
        response["Location"] = uri
        return response
    end

end

    class SeeOther < Redirection; STATUS = 303; end

    class NotModified < Redirection; STATUS = 304; end

    class TemporaryRedirect < Redirection; STATUS = 307; end

class ClientError < HTTPException; 

    def render(env)
        request, response = Request.new(env), Response.new
        response.status = self.class::STATUS
        
        description = "#{self.class.name.split("::").last}: #{message}"
        error "#{request.path_info}\n"\
              "#{description}" if $DBG
        resource = Web::HTMLResource.new(request, response, nil, "/errors/4xx.html")
        resource.scope = {
            "window_title" => "Client error",
            "status" => response.status,
            "message" => CGI.escapeHTML(description),
        }
        resource.handle("get")

        return response
        
    rescue Object => ex
        error "#{ex.class}: #{ex}"
    end

end

    class Unauthorized < ClientError; STATUS = 401; end

    class PaymentRequired < ClientError; STATUS = 402; end

    class Forbidden < ClientError; STATUS = 403; end

    class NotFound < ClientError; STATUS = 404; end
        class MethodNotFound < NotFound; STATUS = 404; end
        class TemplateNotFound < NotFound; STATUS = 404; end

class ServerError < HTTPException; end

    class InternalServerError < ServerError

        STATUS = 500

        def initialize(exception = nil)
            @exception = exception
        end

        def render(env)
            request, response = Request.new(env), Response.new
            response.status = self.class::STATUS

            description = "#{@exception.class.name.split("::").last}: #{@exception.message}"
            error "#{request.path_info}\n"\
                  "#{description}\n"\
                  "#{(@exception.backtrace() || []).join("\n")}"
            resource = Web::HTMLResource.new(request, response, nil, "/errors/5xx.html")
            resource.scope = {
                "window_title" => "Internal Server Error",
                "status" => response.status,
                "message" => CGI.escapeHTML(description),
            }
            resource.handle("get")

            return response

        rescue Object => ex
            error "#{ex.class}: #{ex}"
        end

    end

    class NotImplemented < ServerError; STATUS = 501; end

    class BadGateway < ServerError; STATUS = 502; end

    class ServiceUnavailable < ServerError; STATUS = 503; end

    class GatewayTimeout < ServerError; STATUS = 504; end

end

