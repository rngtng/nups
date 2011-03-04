# monkey patch Array so we have a for_each like method as well

class Array
  
  alias find_each each
end