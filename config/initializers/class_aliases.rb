# Make class names shorter for development/test convenience.

{
  "FactoryGirl" => 'FG'
}.each {|class_name, class_alias|
  begin
    class_alias.constantize # should fail, triggering `rescue` path
    fail "A class with the wanted class alias already exists" # should never be reached
  rescue NameError 
    
    class_name_exists = true
    
    begin
      class_name.constantize # aliased class may not exist (e.g. b/c environment is production)
    rescue
      class_name_exists = false
    end
    
    eval "#{class_alias} = #{class_name}" if class_name_exists
    
  end
}