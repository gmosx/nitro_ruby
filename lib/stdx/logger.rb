require "logger"
require "fileutils"

#--
# Logging helpers. They are shorter and easier to use. 
# Moreover, these methods can be overriden in your class to
# provide granular custom logging.
#
# TODO: 
# - add sync.
# - improve format.
#++

module Kernel 

    def info(msg)
        $olog.info(msg)
    end
    
    def debug(msg)
        $olog.debug(msg)
    end
    
    def error(msg)
        $elog.error(msg)
    end
    
    # Development helper
    
    def p!(*msgs)
        error(msgs.join("\n"))
    end

    def i!(*msgs)
        error(msgs.map{|m| m.inspect}.join("\n"))
    end
    
end

class Logger

    class << self

        def output_to_std
            $olog = Logger.new(STDOUT)
            $elog = Logger.new(STDERR)
        end

        def output_to_files(info_file = "info.log", error_file = "error.log", dir = ".log")
            FileUtils.mkdir_p(dir)
            $olog = Logger.new(File.join(dir, info_file))
            $elog = Logger.new(File.join(dir, error_file))
        end

    end
    
end

# This is needed as default. Prevents nasty errors in case the user forgets 
# setting the Logger output.

Logger.output_to_std 
