require "rack"
require "rack/request"
require "rack/response"

module Web

class Adapter
    class << self
        def run(app, options = {})
            port = options.fetch(:port, 9000)

            case options.fetch(:adapter, :mongrel)
            when :cgi
                Rack::Handler::CGI.run(app)
            when :mongrel
                Rack::Handler::Mongrel.run(app, :Port => port)
            when :webrick
                Rack::Handler::WEBrick.run(app, :Port => port)
            else
                raise "Unknown Rack handler"
            end
        end
    end
end

end

