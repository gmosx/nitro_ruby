require "stdx/uri/update_query"

module Web

# A simple pagination helper. Calculates the sql limit clause.
# We avoid count(*) for scalability reasons.

module Pager

    PAGER_PARAM = "po"
   
private

    #--
    # We check if the collection has limit+1 objects (show prev then).
    #++

    def paginate(collection_key, uri = request.uri)
        limit = @scope.fetch("pager_limit", 10)
        offset = request.fetch(PAGER_PARAM, 0).to_i
        @scope["pager_offset"] = offset
        @scope["pager_next"] = URI.add_param(uri, PAGER_PARAM, offset-limit) unless 0 == offset
        @scope["pager_prev"] = URI.add_param(uri, PAGER_PARAM, offset+limit) if @scope[collection_key].size > limit
        return offset        
    end

    #--
    # We fetch limit+1 records to check if we should display the previous link
    #++
    
    def pager_limit(limit = 10)
        @scope["pager_limit"] = limit
        offset = request.fetch(PAGER_PARAM, "0")
        return "LIMIT #{limit+1} OFFSET #{offset}"
    end
    
end

end
