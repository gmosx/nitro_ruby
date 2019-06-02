require "stdx/module/properties"
require "stdx/module/liquid"

module DB

# Classes that include this module are managed by the DB framework.
# For extra convienience they also export a LiquidDrop interface.

module Managed 

    module ClassMethods

        # Deserialize an object by id.
        # Returns nil if now object is found.
        
        def load(id)
            if row = $db.select_one("SELECT * FROM #{sql_table} WHERE id=?", id)
                return self.new_from_dbi_row(row)
            end
        end

        # Perfom a select query that returns one object, deserialize.
        # Returns nil if now object is found.
        #
        # Example:
        #     User.one("name from $ where name=?", name)
        #--
        # THINK: remove $ alias? --> YES!!
        # replace $ with `table`
        #++

        def select_one(sql, *bindvars)
            $db.load_one(self, "SELECT #{sql}".gsub(/\$/, sql_table), *bindvars)
        end
        alias_method :select, :select_one

        def one(sql, *bindvars)
            $db.load_one(self, sql, *bindvars)
        end

        # Perform a select query and deserialize the results.
        # Returns nil if now objects are found.
        #
        # Example:
        #
        #     User.all("name from $ where age>?", 18)
       
        def select_all(sql, *bindvars)
            $db.load_all(self, "SELECT #{sql}".gsub(/\$/, sql_table), *bindvars)
        end
        
        def all(sql, *bindvars)
            $db.load_all(self, sql, *bindvars)
        end
        
        # Delete an object by id.
        
        def delete(id)
            db_update_callback(id)
            $db.do("DELETE FROM #{sql_table} WHERE id=?", id)
        end
    
        # Delete many instances of the object.
            
        def delete_all(where, *bindvars)
            db_update_callback()
            $db.do("DELETE FROM #{sql_table} #{where}", *bindvars)
        end

        # The name of the sql table that stores this class.

        def sql_table
            self.name.gsub(/::/, "")
        end

        # Create an instance of the class from a DBI::Row object.
    
        def new_from_dbi_row(row)
            obj = self.new
            props = self.property_annotations
            
            row.column_names.each_with_index { |n, idx|
                # TODO: mysql timestamp is returned as a string, needs Time.parse.
                obj.instance_variable_set("@#{n}", row[idx])
            }        

            return obj
        end

        # Override this callback to perform custom logic.
        
        def db_update_callback(id = nil)
        end
        
        # Override this callback to perform custom logic.
        
        def db_delete_callback(id = nil)
        end

    end

    # --------------------------------------------------------------------------

    #--
    # TODO: optimize / cleanup this.
    #++
        
    def self.included(base)
        base.send(:include, Properties)
        base.send(:include, LiquidMethods)
        
        base.metaclass.send(:include, ClassMethods)

        (@subclasses ||= []) << base if base.is_a? Class
       
        # Propagate properties and DB::Managed to subclasses.
         
        base.module_eval do
            def self.inherited(subclass)
                subclass.send(:include, DB::Managed)
                super
            end
        end
        
        super
    end
    
    # Returns the managed classes.
    # http://ola-bini.blogspot.com/2007/07/objectspace-to-have-or-not-to-have.html
    
    def self.subclasses
        @subclasses
    end

    # --------------------------------------------------------------------------
    
    # The primary key of the managed object.
    #--
    # Overides the default id method that points to object_id.
    #++
    
    def id
        @id
    end

    # Populate the object attributes from a hash.
    # Returns self for chaining.
    # Uses the attribute writer instead of the instance variable
    # to be more transparent.
    
    def assign_with(hash)
        hash.each { |k, v| 
            next if k == "id"
            awriter = "#{k}="
            if respond_to? awriter
                case v
                when "@@TIME"
                    v = Time.local(
                        hash["#{k}_year"].to_i,
                        hash["#{k}_month"].to_i,
                        hash["#{k}_day"].to_i,
                        hash["#{k}_hour"].to_i,
                        hash["#{k}_min"].to_i,
                        hash["#{k}_sec"].to_i
                    )
                when "@@DATETIME"
                    v = DateTime.new(
                        hash["#{k}_year"].to_i,
                        hash["#{k}_month"].to_i,
                        hash["#{k}_day"].to_i,
                        hash["#{k}_hour"].to_i,
                        hash["#{k}_min"].to_i,
                        hash["#{k}_sec"].to_i
                    )
                end
                send(awriter, v)
            end
        }
        return self
    end

    # Insert or update the object in the database.
    # If the object has a valid id, the database representation is updated,
    # else the object is inserted into the database.
    
    def save!
        if @id and @id.to_i > 0
            update_all!
        else
            insert!
        end
    end

    # Insert an object into the database.
    #--
    # TODO: precompile the SQL query, use method_missing?
    #++
    
    def insert!
        klass = self.class
        
        qs = []
        names = []
        bindvars = []

        klass.property_names.each { |n|
            names << n
            qs << "?"
            bindvars << instance_variable_get("@#{n}")
        }
        
        $db.do(
            "INSERT INTO #{klass.sql_table} (#{names.join(', ')}) VALUES (#{qs.join(', ')})", 
            *bindvars
        )
        
        @id = $db.handle.func(:insert_id)
        
        klass.db_update_callback(@id)
    end

    # The update set for all properties.
    # Returns the set and the corresponding bindvars.
    
    def update_set
        set = []
        bindvars = []

        self.class.property_names.each { |n|
            set << "#{n}=?"
            bindvars << instance_variable_get("@#{n}")
        }
        
        return set.join(","), bindvars
    end

    # Update all fields of an existing object in the database.
    #--
    # TODO: precompile with method_missing.
    #++
    
    def update_all!
        klass = self.class

        set, bindvars = update_set()
        
        $db.do(
            "UPDATE #{klass.sql_table} SET #{set} WHERE id=#{@id}", 
            *bindvars
        )
        
        klass.db_update_callback(@id)
    end

	# Update specific fields.
	
    def update(set, *bindvars)
        klass = self.class

        $db.do(
            "UPDATE #{klass.sql_table} SET #{set} WHERE id=#{@id}", 
            *bindvars
        )
    end

    # Update specific fields, fire the callback.
    
    def update!(set, *bindvars)
		super        
        klass.db_update_callback(@id)
    end

end

end

