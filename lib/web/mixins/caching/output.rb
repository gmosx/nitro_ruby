require "md5"

require "stdx/file/write"

module Web

# Caching is the ultimate form of optimization. This module
# provides efficient methods for response and fragment caching.

module Caching

    def self.remove_cached_output(path)
        begin
            File.delete("public#{path}")
        rescue 
        end
    end
    
private

    def cache_output!
        @scope["CACHE_OUTPUT"] = true unless $DBG
    end

    def write_output_to_fs(output)
        path = "public#{@request.path_info}"
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, output)    
    end
    
end

end

