module Web

# YUI helpers and utilities.
#--
# script_loader -> SCRIPT_LOADER
#++

module YUI 

private

    def yui_require(*scripts)
        sl = @scope.fetch("script_loader", [])

        for script in scripts
            sl << script
        end
        
        sl.uniq!
        
        @scope["script_loader"] = sl
    end

end

end
