require "cgi"
require "base64"
require "digest/sha2"

require "json/ext"

require "utils/times"
require "utils/settings"

require "web/application"
require "apps/id/model/user"

module Web

# A session is a hash that holds session variables.

class Session < Hash

    setting :key, :value => "ns"
    setting :key_client, :value => "nsc"
    setting :path, :value => "/"
    setting :secret, :value => ENV.fetch("NITRO_SESSION_SECRET", "changeme")
    setting :ttl, :value => 1.year

    attr_accessor :flash
            
    def []=(key, val)
        super
        @dirty = true
    end
    
    def delete(key)
        @dirty = true
        super
    end
    
    def dirty?
        @dirty
    end
    
    # Flash session variables.
    #
    # Examples:
    #
    #   session.flash "msg", "Invalid data" # set the variable
    #   session.flash "msg" # get the variable
    
    def flash(key, val = nil)
        if val
            @dirty = true
            (self["FLASH"] ||= {})[key] = val
        else
            @dirty = true
            @flash ||= self.delete("FLASH")
            return @flash[key] if @flash
        end
    end
    
    # Optimize the session object for serialization by removing empty keys
    # and transient data.

    def pack!
        @dirty = nil
        @flash = nil 
        delete("FLASH") if (f = self["FLASH"] and f.empty?) 
        delete_if { |k, v| v == nil }
    end
    
    def user
        self["USER"]
    end

end

# Implements a cookie based Session store.
#--
# THINK: are CGI.escapes needed?
#++

class << Session

    MAX_DATA_SIZE = 4096 - 256 - 2 - 32
    
    # Deserialize the session.
    
    def load(request)
        data = request.cookies[Session::key]
        return decode(data)
    rescue => ex
        debug ex.to_s if $DBG
        return Session.new
    end
    
    # Serialize the session (only if dirty!)
    # Creates one protected cookie for use on the server, and another, 
    # unprotected cookie for use by the client. The server cookie is marked as
    # HttpOnly (http://msdn.microsoft.com/en-us/library/ms533046.aspx)
    
    def save(session, response)
        if session and session.dirty?
            data = encode(session)
            
            if data.size > MAX_DATA_SIZE
                error "Session data size exceeds the cookie limit!"
            else
                response.set_cookie(
                    Session::key, 
                    :value => data,
                    :path => Session::path,
                    :domain => Application::domain,
                    :expires => Time.now + Session::ttl,
                    :http_only => true
                )

                response.set_cookie(
                    Session::key_client, 
                    :value => encode_client(session),
                    :path => Session::path,
                    :domain => Application::domain,
                    :expires => Time.now + Session::ttl
                )
            end            
        end
    end

private

    # Base64 encoding is used to make the marshaled data HTTP 
    # header friendly. A crypto hash is added for extra security.
    
    def encode(session)
        session.pack!
        
        data = Base64.encode64(Marshal.dump(session))
        hash = Digest::SHA256.hexdigest("#{data}#{Session::secret}")

        return CGI.escape("#{data}--#{hash}")
    end
            
    # Decode the encoded session data. Returns a new session on altered data.
        
    def decode(data)
        data, hash = CGI.unescape(data).split("--")
        
        if hash == Digest::SHA256.hexdigest("#{data}#{Session::secret}")
            return Marshal.load(Base64.decode64(data))    
        else
            return Session.new
        end 
    end
    
    # Encode the data for client access.
    
    def encode_client(session)
        return CGI.escape(Base64.encode64(session.to_json))
    end

end

module SessionManagement

private

    # Access the session variables.
    # The session is lazily loaded.
    
    def session
        @session ||= Session.load(@request)
    end
   
end

end

