#--
# FIXME: hack conversion of datetime to time.
#++

module Atom

class << self
    
    def encode_all(obj_list, options = {})
        feed = %{<?xml version="1.0" encoding="#{options.fetch(:encoding, 'utf-8')}" ?>
        <feed xmlns="http://www.w3.org/2005/Atom">
            <id>#{Time.now.to_i}</id>
            <title>#{options[:title]}</title> 
            <generator uri="http://www.nitroproject.org">Nitro</generator>
            <link href="#{options[:uri] || options[:link]}"/>
            <updated>#{iso_time(options[:updated])}</updated>
        }
        
        if author = options[:author]
            feed << %{
                <author> 
                    <name>#{author}</name>
                </author> 
            }
        end
        
        for obj in obj_list
            feed << encode(obj)          
        end
        
        feed << %{
        </feed>}
        
        return feed
    end

    #--
    # TODO: add author, links, and more.
    #++
    
    def encode(obj)
        %{<entry>
            <title>#{obj.title}</title>
            <link href="#{obj.uri}"/>
            <id>#{obj.id}</id>
            <published>#{iso_time(obj.created)}</published>
            <updated>#{iso_time(obj.updated)}</updated>
            <content type="html">#{CGI.escapeHTML(obj.safe_summary)}</content>
        </entry>}
    end
    
    def iso_time(dt)
        if dt
            Time.gm(dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec, 0.0).iso8601
        else
            Time.now.iso8601
        end
    end
    
end

end

__END__

    <summary><![CDATA[#{obj.summary}]]></summary>

