class Post < ActiveRecord::Base
  # attr_accessor removed - these are database columns, not virtual attributes
  # Having attr_accessor here prevents the values from being saved to the database
end
