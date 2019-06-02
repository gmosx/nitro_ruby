
#--
# Extensions for the standard URI module.
#++

module URI

    # Add a param to the query string. Fast!
    #
    # Example:
    #   URI.add_param("http://www.site.com?id=2", "page", 2)

    def self.add_param(uri, key, val)
        uri = uri.dup

        if uri =~ /\?/
            unless uri.sub!(/#{key}=([^&|^;]*)/, "#{key}=#{val}")
                uri = "#{uri}&#{key}=#{val}"
            end

            return uri
        else
            "#{uri}?#{key}=#{val}" 
        end
    end

end

module URI

class Generic

    # Update the query string with extra parameters.
    #
    # Example:
    #   uri = URI.parse("http://www.site.com?id=2")
    #   uri.update_query("po" => 2)
    #   puts uri

    def update_query(params)
        if q = self.query
            new_params = []
            params.each { |k, v|
                unless q.sub!(/#{k}=([^&|^;]*)/, "#{k}=#{v}")
                    new_params << "#{k}=#{v}"
                end
            } 
            unless new_params.empty?
                self.query = "#{q}&#{new_params.join('&')}"
            end
        else
            self.query = params.map{ |k, v| "#{k}=#{v}" }.join("&")
        end
    end

    # Add a param to the query string. Faster than
    # update_query.
    #
    # Example:
    #   uri = URI.parse("http://www.site.com?id=2")
    #   uri.add_param("po", 2)
    #   puts uri

    def add_param(key, val)
        if q = self.query
            if q.sub!(/#{key}=([^&|^;]*)/, "#{key}=#{val}")
                self.query = q
            else
                self.query = "#{q}&#{key}=#{val}"
            end
        else
            self.query = "#{key}=#{val}" 
        end
    end

end

end


__END__

uri = URI.parse("http://www.me.gr?id=2")
uri.update_query("po" => 2, "id" => 5, "lala" => "gmosx")
puts uri

uri = URI.add_param("http://www.site.com?id=2&lala=3", "id", 17)
puts uri
