require "md5"

require "utils/memcache_client"

module Web

# Caching is the ultimate form of optimization. This module
# provides efficient methods for response and fragment caching.

module Caching

private

    SERIAL = 5

    # Cache the complete response. The request.uri is used as a key.
    # Also leverages HTTP caching (ETag).
  
    def cache_response(key = nil, expire = 0)
        key = "#{request.uri}:#{key}:#{SERIAL}"

        # 'compress' the key (memcache may be picky with chars).        

        etag = key = MD5.hexdigest(key)
      
        # first handle HTTP caching, avoids a memcache hit and saves 
        # a huge amount of bandwidth to the client.

        if @request.env["HTTP_IF_NONE_MATCH"] == etag
            @response["X-Cache"] = "HTTP"
            raise NotModified.new
        end

        cached_body, status, header = Cache.get(key)
        
        if cached_body
            @response = Web::Response.new(cached_body, status, header)
            @response["X-Cache"] = "HIT"
        else
            @response["ETag"] = etag
            @response["Cache-Control"] = "max-age=#{expire}" if expire > 0
            @response["X-Cache"] = "MISS"

            yield

            Cache.put(key, [@response.body, @response.status, @response.header], expire)
        end            
    end
    alias_method :cache, :cache_response

    # Cache a fragment of the page. No HTTP caching.
    
    def cache_fragment(key = nil, expire = 0)
        key = "#{key}:#{SERIAL}"
      
        if fragment = Cache.get(key)
            print(fragment)
        else
            open_buffer
            
            yield
            
            fragment = close_buffer
            Cache.put(key, fragment, expire)
            print(fragment)
        end            
    end

    # Dump the response body to the public directory, to be 
    # served by the webserver. Dumped pages are manually expired.
        
    def dump_response
    end

end

end

