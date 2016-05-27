Puppet::Type.type(:decorator).provide(:decorator) do
  desc "Decorate a resource with a resource to run before refresh"


  def decorator
    puts "hello world"

    catalog_resource = @resource[:resource]
    puts "********* let the mayhem commenceth *********"

    puts catalog_resource
  end
 
  def decorator?
    true
  end

  # we are always needed if we are active
  #def before_refresh? 
  #  true
  #end

end
