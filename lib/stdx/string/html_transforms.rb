require "cgi"

class String

=begin
    # Strips any html markup from a string (Quick?)
    # There is also html_filter.
    
    SH_TAG_KEY = SH_ATTRIBUTE_KEY = /[\w:_-]+/
    SH_ATTRIBUTE_VALUE = /(?:[A-Za-z0-9]+|(?:'[^']*?'|"[^"]*?"))/
    SH_ATTRIBUTE = /(?:#{SH_ATTRIBUTE_KEY}(?:\s*=\s*#{SH_ATTRIBUTE_VALUE})?)/
    SH_ATTRIBUTES = /(?:#{SH_ATTRIBUTE}(?:\s+#{SH_ATTRIBUTE})*)/
    TAG = %r{<[!/?\[]?(?:#{SH_TAG_KEY}|--)(?:\s+#{SH_ATTRIBUTES})?\s*(?:[!/?\]]+|--)?>}
    
    def html_strip
        self.gsub(TAG, "").gsub(/\s+/, " ").strip
    end
=end

    #--
    # TODO: remove this, use CGI.escapeHTML instead!!
    #++
    
    def html_strip
        CGI.escapeHTML(self)
    end
    
    # A quick and dirty fix to add 'nofollow' to any urls in a string.
    # Decidedly unsafe, but will have to do for now.

    def nofollowify
        self.gsub(/<a(.*?)>/i, '<a\1 rel="nofollow">')
    end

end

