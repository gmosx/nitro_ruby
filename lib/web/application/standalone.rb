# Run a standalone application.

require "rubygems"
require "web"
require "db"

class StandaloneApplication < Web::Application

    def call(env)
        parse_arguments
        path = $0.gsub(/\.rb$/, "").gsub(/^\.\//, "").gsub(/^resources/, "")
        env["PATH_INFO"] = path
        env["REQUEST_METHOD"] = @http_method
        env["QUERY_STRING"] = @query_string
        env["CONTENT_TYPE"] = "text/html"
        env["HTTP_HOST"] = "cmd.shell"
        super(env)
    end

    def parse_arguments
        require "optparse"

        options = OptionParser.new do |opts|
            opts.banner = "Usage: ruby #$0 [options,..]"
            
            opts.on("-m", "--method meth", "HTTP method") do |meth|
                @http_method = meth
            end

            opts.on("-q", "--query query", "The query string") do |query|
                @query_string = query
            end

            opts.on("-x", "--exec execution mode", "The execution mode (dev, stage, live)") do |mode|
                @mode = mode.downcase.to_symbol
                $DBG = nil unless :debug == @mode
            end
        end    
        
        options.parse(ARGV)
    end

end

END {
    StandaloneApplication.new.run(:adapter => :cgi)
}
