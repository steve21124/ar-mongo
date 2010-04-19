module MongoScaffold
  
  class Connection
    def quote_column_name(name)
      "#{name}"
    end      
    
    def quote_column_name=(name)
      
    end
  end
  
  class Base
    include MongoMapper::Document
    
    key :name, String
    
    
    class << self
      
      def collection_info
        # unless defined? @@collection_info
        #         file = ENV['SCHEMA'] || 'db/schema.rb'
        #         load(file)
        #         @@collection_info = ActiveRecord::Schema.collection_info
        #       end
        #       @@collection_info
      end
                             
      def table_name 
        self.class.name.downcase
      end
      
      def default_scoping 
        []
      end  
      
      def primary_key 
        "_id"
      end
      
      def connection
        con = Connection.new
      end
      
      def reflect_on_all_associations
        a = ActiveRecord::Reflection::AssociationReflection.new(:belongs_to, 'project', {}, {})
        [a]
        # self.keys.select{ |k,v| v.type == ObjectId }
      end

      def reflect_on_association(association)
        nil
      end
      
      # def reflect_on_association(association)
      #   reflections[association].is_a?(AssociationReflection) ? reflections[association] : nil
      # end
      

      
      def columns 
        unless @columns          
          @columns = self.keys.collect {|k,v| 
            unless k.empty?
              col = ActiveRecord::ConnectionAdapters::Column.new(k, '', v.type, v.default_value)
              col
            end
          }
          # @columns = collection_info[table_name].columns.collect { |col_def|
          #             col = ActiveRecord::ConnectionAdapters::Column.new(col_def.name, col_def.default, col_def.sql_type, col_def.null)
          #             col.primary = col.name == primary_key
          #             col
          #           }
        end
        @columns
      end            
      
      def columns_hash
        self.keys
      end
    end
    
  end
  
  include AutoCode
  
  class << self                            
    
    def write_schema
      
    end
    
    def init_mongo_models
      MongoMapper.connection = Mongo::Connection.new('localhost')
      MongoMapper.database = 'auto_scaffold-development'
      
      CollectionSchema.all.each { |klass|         
        create_class(klass.name) do 
          def self.hello 
            puts "Hi from #{self.name}"
          end
        end
      }
    end
        
    def create_class(name, &block)
      new_constant = Class.new(ActiveRecord::Base)
      ret = Kernel.const_set( name, new_constant )
      new_constant.module_eval( &block ) if block
      ret
    end
    
    def class_exists?(class_name)
      false
    end 
  end
end

# include MongoScaffold