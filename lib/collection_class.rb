# Define basic collection schema class, wich define collections classes 
class CollectionSchema 
  include MongoMapper::Document
  key :name, String
  key :definition, String
end