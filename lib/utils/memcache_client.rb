require "memcache"

# A utility wrapper around the MemCache client to simplify cache 
# access. All methods silently ignore MemCache errors.
#--
# TODO: add sync.
#++

module Cache

    def self.get_cache
        $memcache ||= MemCache.new("127.0.0.1", :multithread => true)
    end

    # Returns the object at +key+ from the cache if successful, or 
    # nil if either the object is not in the cache or if there was 
    # an error attermpting to access the cache.

    def self.get(key, expiry = 0)
        get_cache.get(key)
    rescue MemCache::MemCacheError => err
        $memcache = nil if err.message == "No connection to server"
        error "MemCache Error: #{err.message}"
        # gmosx: return an indicator here?
        return nil 
    end

    # Sets +value+ in the cache at +key+, with an optional +expiry+ time in
    # seconds.

    def self.put(key, value, expiry = 0)
        get_cache.set(key, value, expiry)
        return value
    rescue MemCache::MemCacheError => err
        error "MemCache Error: #{err.message}"
        return nil 
    end

    # Sets +value+ in the cache at +key+, with an optional +expiry+ time in
    # seconds.  If +key+ already exists in cache, returns nil.

    def self.add(key, value, expiry = 0)
        response = get_cache.add(key, value, expiry)
        (response == "STORED\r\n") ? value : nil
    rescue MemCache::MemCacheError => err
        return nil
    end

    # Deletes +key+ from the cache in +delay+ seconds.

    def self.delete(key, delay = nil)
        get_cache.delete(key, delay)
        return nil
    rescue MemCache::MemCacheError => err
        return nil
    end

    # Resets all connections to MemCache servers.

    def self.reset
        get_cache.reset
        return nil
    end

end


__END__

CACHE = MemCache.new :c_threshold => 10_000,
                     :compression => true,
                     :debug => false,
                     :namespace => 'my_namespace_test',
                     :readonly => false,
                     :urlencode => false
