
# Useful links:
#
# - http://www.ietf.org/rfc/rfc3023.txt
# - http://annevankesteren.nl/2004/08/mime-types
# - http://www.xml.com/pub/a/2004/07/21/dive.html

module MIME

# Information about a specific MIME type.

TypeInfo = Struct.new(:content_type, :extension, :convert_method, :headers) 

# Maps extensions to MIME types.

EXTENSION_TO_MIME = {
    "txt" => TypeInfo.new("text/plain", "txt", :to_s),
    "html" => TypeInfo.new("text/html", "html", :to_html),
    "xhtml" => TypeInfo.new("application/xhtml+xml", "xhtml", :to_html),
    "xml" => TypeInfo.new("text/xml", "xml", :to_xml),
    "action" => TypeInfo.new("application/nitro+action", "action"),
    "atom" => TypeInfo.new("application/xml", "atom", :to_atom),
    # application/atom+xml is not (yet) a standard and thus not supported 
    # by browsers.
    # "atom" => TypeInfo.new("application/atom+xml", "atom", :to_atom),
    "rdf" => TypeInfo.new("application/rdf+xml", "rdf", :to_rdf),
    "rss" => TypeInfo.new("application/xml", "rss", :to_rss),
    # application/atom+xml is not (yet) a standard and thus not supported 
    # by browsers.
    # "rss" => TypeInfo.new("application/rss+xml", "rss", :to_rss),
    "js" => TypeInfo.new("text/javascript", "js"), 
    "css" => TypeInfo.new("text/css", "css"),
    "png" => TypeInfo.new("image/png", "png"),
    "gif" => TypeInfo.new("image/gif", "gif"),
    "jpg" => TypeInfo.new("image/jpeg", "jpg"),
    "jpeg" => TypeInfo.new("image/jpeg", "jpg")
}

# Maps content types to MIME types.
#--
# Generated from the above map.
#++

CONTENT_TYPE_TO_MIME = {}

for ext, mime in EXTENSION_TO_MIME
    CONTENT_TYPE_TO_MIME[mime.content_type] = mime
end

end

