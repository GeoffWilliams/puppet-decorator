require 'puppet/application/resource'
Puppet::Type.type(:decorator).provide(:decorator) do
  desc "Decorate a resource with a resource to run before refresh"


  def decorator
    puts "I WOULD RUN LALALA"
    # if we are supposed to run, just run each resource right now
    @resource[:before_refresh].any? { | reference |    
      # fetch the catalogue representation for each resource ref
      res = Puppet::Resource.new(reference)
      reference.catalog = resource.catalog
      resource_cat = reference.catalog.resource(res.to_s)

      puts "set a resource to noop==false"
      resource_cat.noop = false
      #require 'pry'
      #binding.pry
      #puts "sending refresh"
      #resource_cat.refresh
    }
  end
 
  def decorator?
    reference = @resource[:resource]

    # lookup the CURRENT state of the resource on the system
 
    # WTF is this not needed?
    #resource_key = [reference.type, reference.name].join('/')
    resource_key = reference.name
    puts resource_key
    resource_now = Puppet::Resource.indirection.find(resource_key)
    resource_now_ensure = resource_now.to_data_hash["parameters"][:ensure]
    resource_now_hash = resource_now.to_data_hash["parameters"]

    puts "resource_now" + resource_now_ensure.to_s
    fire=false

    # lookup the DESIRED state of the resource in the catalog
    res = Puppet::Resource.new(reference)
    reference.catalog = resource.catalog
    resource_cat = reference.catalog.resource(res.to_s)
    if resource_cat == nil
      fail("reference #{resource_key} was not found in the catalog")
    end  
  
    resource_cat.properties.any? do |property|
      is = resource_now_hash[property.name]
      puts "want" + is.to_s
      if property.should && !property.safe_insync?(resource_now_hash[property.name])
	puts "FIRE!"
        fire=true
      end
    end
    fire
  end

end
