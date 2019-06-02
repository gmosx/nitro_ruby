require "optparse"

module Web

class Application

private

    def parse_arguments
        options = OptionParser.new do |opts|
            opts.banner = "Usage: ruby #$0 [options,..]"
            
            opts.on("-m", "--method", "HTTP method") do |m|
                @http_method = m
            end

            opts.on("-q", "--query", "The query string") do |q|
                @query_string = q
            end
            
            opts.on("-d", "--daemon", "Run as daemon") do
                require "daemons"

                pwd = Dir.pwd
                Daemons.daemonize
                Dir.chdir(pwd)
                FileUtils.mkdir_p(".tmp")
                FileUtils.touch(File.join(".tmp", "a#{Process.pid}.pid"))
            end

            opts.on("-m", "--mode execution mode", "The execution mode (dev, stage, live)") do |mode|
                @mode = mode.downcase.to_symbol
                $DBG = nil unless :debug == @mode
            end

            opts.on("-p", "--port listen port", "The listen port") do |port|
                @settings[:port] = port
            end
        end    
        
        options.parse(ARGV)
    end

end

end


__END__

articles/show -m get -q id=1&mode=full
articles/show id=1&mode=full
articles/show --delete id=1
articles --post title=dadsa&ver=1
articles --post -f posdata.xml


