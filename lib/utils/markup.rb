require "utils/html_filter"

# Format a string. Typically used to format text fields 
# for html presentation.

module Markup

    class << self

        def expand(str)
            if str
                str.html_filter.gsub(/\n/, "<br />")
            end
        end 

        def compact(str)
            if str
                str.gsub(/<br \/>/, "\n")
            end
        end
        alias_method :original, :compact

    end

end

