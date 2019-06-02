require "rack/request"

module Web

# Encapsulates a Web request.
#
# Links:
#   http://hoohoo.ncsa.uiuc.edu/cgi/interface.html

class Request < Rack::Request

    def initialize(env)
        super
        # CGI fix
        @env["PATH_INFO"] ||= @env["REQUEST_URI"].split("?").first
        @env["PATH_INFO"] = "/index.html" if @env["PATH_INFO"] == "/"         
    end

    def has?(key)
        val = params[key] and val and val != ""
    end

    # Allow HTTP method override.
    #
    # === Example
    # http://site.com/article/1?_method=DELETE    
    
    def request_method
         @method ||= params["_method"] || @env["X-HTTP-Override-Method"] || @env["REQUEST_METHOD"]
    end

    # The path of the request.
    
    def path
        path_info || @env["REQUEST_URI"].split("?").first
    end
    
    # Return the host uri (including the protocol part).       
    
    def host_uri
        "#{scheme}://#{host}"
    end
    
    def uri
        "#{host_uri}#{@env["REQUEST_URI"]}"
    end

    def fetch(k, default)
        params.fetch(k, default)
    end

    # Returns true if the request"s "X-Requested-With" header contains
    # "XMLHttpRequest". 
    
    def xml_http_request?
        !(@env["HTTP_X_REQUESTED_WITH"] !~ /XMLHttpRequest/i)
    end
    alias_method :xhr?, :xml_http_request?    


    # Returns the domain part of a host, such as site.com in 
    # "www.site.com". You can specify a different <tt>tld_length</tt>, 
    # such as 2 to catch site.co.uk in "www.site.co.uk".
    
    def domain(tld_length = 1)
      # return nil unless named_host?(host)
      host.split(".").last(1 + tld_length).join(".")
    end

    # Which IP addresses are "trusted proxies" that can be stripped from
    # the right-hand-side of X-Forwarded-For
    
    TRUSTED_PROXIES = /^127\.0\.0\.1$|^(10|172\.(1[6-9]|2[0-9]|30|31)|192\.168)\./i

    # Determine originating IP address.  REMOTE_ADDR is the standard
    # but will fail if the user is behind a proxy.  HTTP_CLIENT_IP and/or
    # HTTP_X_FORWARDED_FOR are set by proxies so check for these if
    # REMOTE_ADDR is a proxy.  HTTP_X_FORWARDED_FOR may be a comma-
    # delimited list in the case of multiple chained proxies; the last
    # address which is not trusted is the originating IP.

    def remote_ip
        if TRUSTED_PROXIES !~ @env["REMOTE_ADDR"]
            return @env["REMOTE_ADDR"]
        end

        if @env.include? "HTTP_CLIENT_IP"
            if @env.include? "HTTP_X_FORWARDED_FOR"
                # We don"t know which came from the proxy, and which from the user
                raise <<-EOM
                IP spoofing attack?!
                HTTP_CLIENT_IP=#{@env["HTTP_CLIENT_IP"].inspect}
                HTTP_X_FORWARDED_FOR=#{@env["HTTP_X_FORWARDED_FOR"].inspect}
                EOM
            end
            return @env["HTTP_CLIENT_IP"]
        end

        if @env.include? "HTTP_X_FORWARDED_FOR"
            remote_ips = @env["HTTP_X_FORWARDED_FOR"].split(",")
            while remote_ips.size > 1 && TRUSTED_PROXIES =~ remote_ips.last.strip
                remote_ips.pop
            end

            return remote_ips.last.strip
        end

        return @env["REMOTE_ADDR"]
    end

end

end
