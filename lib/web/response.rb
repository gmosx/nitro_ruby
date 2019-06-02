require "rack/response"

require "utils/mime"
require "utils/settings"

module Web

class Response < Rack::Response

    setting :charset, :value => "utf-8"
    
    attr_reader :mime

    # Set the content type.
        
    def set_content_type(ctype)
        headers["Content-Type"] = "#{ctype};charset=#{Response.charset}"
    end
    
    # Select the mime type to be used in the response.

    def select_mime(request, ext = nil)
        if ext
            @mime = MIME::EXTENSION_TO_MIME[ext]
        else
            # TODO: also consider the HTTP Accept heade
            @mime = MIME::EXTENSION_TO_MIME["html"]
            request.path_info << ".html" # FIXME: NOOO!!!
        end

        set_content_type(@mime.content_type) if @mime
        return @mime
    end
    
end

end
