require "stdx/logger"

require "utils/settings"

require "web/exceptions"
require "web/application/adapter"
require "web/application/dispatcher"

module Web

# Base class for web applications.

class Application

    setting :domain, :value => "localhost"

    include Web::Dispatcher

    attr_reader :mode

    attr_reader :settings
    
    def initialize
        @mode = :debug
        @dispatch_map = {}
        return self
    end

    # Start the application.
    
    def start(options = {})
        configure(options)
        options[:port] ||= @settings[:port]
        info "Starting application in #{@mode} mode."
        return self
    end
    
    # Stop the application
    
    def stop
        $db.close if $db
    end

    # Run the application.
    
    def run(options = {})
        start(options)
        Web::Adapter.run(self, options)
        stop()
    end

    # Implement the Rack API.
    #--
    # TODO: simplify / Possibly custom handling of redirects.
    #++
        
    def call(env)
        resource, method, response = dispatch(env)
        resource.handle(method)

    rescue Object => ex
        ex = InternalServerError.new(ex) unless ex.respond_to?(:render)
        response = ex.render(env)
    ensure
        Session.save(resource.instance_variable_get("@session"), response) if resource
        return response.finish
    end
    
private

    def configure(options)
        @mode = (ENV["NITRO_EXECUTION_MODE"] || ENV["RACK_ENV"] || "debug").to_sym

        @settings = Settings.configure_xml(File.join("etc", @mode.to_s, "settings.xml"))

        Logger.output_to_files        
        
        unless options[:adapter] == :cgi
            require "web/application/optparse"
            parse_arguments
        end
        
        if db = @settings[:db]
            $db = DB::Database.new(db)
        end
    end

end

end
