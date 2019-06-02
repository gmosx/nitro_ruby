
module DB

# Abstracts an RDBMS. 
# Powered by DBI.

class Database

    attr_accessor :handle
    attr_accessor :options

    def initialize(options = {})
        @options = options
        @options[:host] ||= "localhost"
        @options[:password] ||= ENV["NITRO_DB_PASSWORD"]
        connect!
    end  

    def close
        @handle.disconnect if @handle
    end
    alias_method :disconnect, :close

	# Actually connect to the RDBMS. Initializes a handle (connection).
	
    def connect!
        @handle = DBI.connect("DBI:Mysql:#{@options[:database]}:#{@options[:host]}", @options[:user], @options[:password])
    end
    
    def with
        dbh = @handle
        yield dbh
        # TODO: release handle
    rescue DBI::DatabaseError => ex
        if ex.err == 2006 # 2006  (CR_SERVER_GONE_ERROR) / MySQL server has gone away
            connect!
            retry
        else
            raise
        end        
    end
   
   	# Perform a query that updates the database. 
   	# Returns the number of rows modified.
   	
    def do(sql, *bindvars)
        debug("#{sql} : #{bindvars.inspect}") if $DBG
        return @handle.do(sql, *bindvars)
    rescue DBI::DatabaseError => ex
        if ex.err == 2006 # 2006  (CR_SERVER_GONE_ERROR) / MySQL server has gone away
            connect!
            retry
        else
            raise
        end        
    end
    alias_method :exec, :do

	# Perform a query that returns one result.
	
    def select_one(sql, *bindvars)
        debug("#{sql} : #{bindvars.inspect}") if $DBG
        return @handle.select_one(sql, *bindvars)
    rescue DBI::DatabaseError => ex
        if ex.err == 2006 # 2006  (CR_SERVER_GONE_ERROR) / MySQL server has gone away
            connect!
            retry
        else
            raise
        end        
    end
    alias_method :one, :select_one

	# Rerform a query that returns many results.
	
    def select_all(sql, *bindvars)
        debug("#{sql} : #{bindvars.inspect}") if $DBG
        return @handle.select_all(sql, *bindvars)
    rescue DBI::DatabaseError => ex
        if ex.err == 2006 # 2006  (CR_SERVER_GONE_ERROR) / MySQL server has gone away
            connect!
            retry
        else
            raise
        end        
    end
    alias_method :all, :select_all

    # Perform a query that returns one result and deserialize it into
    # an object of the given class.
    
    def load_one(klass, sql, *bindvars)
        if row = select_one(sql, *bindvars)
            return klass.new_from_dbi_row(row)
        end
    end

    # Perform a query that returns one result and deserializes them into
    # an array of objects of the given class.

    def load_all(klass, sql, *bindvars)
        if rows = select_all(sql, *bindvars)
            return rows.map { |row| klass.new_from_dbi_row(row) } 
        end
    end
    
    # Prepare a statement.
    
    def prepare(sql)
        debug("prepare statement: #{sql}") if $DBG
        return @handle.prepare(sql)
    end

end

end
