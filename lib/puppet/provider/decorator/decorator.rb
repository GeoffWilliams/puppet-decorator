require 'puppet/application/resource'
Puppet::Type.type(:decorator).provide(:decorator) do
  desc "Decorate a resource with a resource to run before refresh"


  def decorator
    # Iterate all passed in resource references if we have been told to run
    @resource[:before_refresh].any? { | reference |    
      # fetch the catalogue representation for each resource ref
      res = Puppet::Resource.new(reference)
      reference.catalog = resource.catalog
      resource_cat = reference.catalog.resource(res.to_s)

      # turn off noop mode so the resource will run IN THE ORDER SPECIFIED
      # IN THE MANIFEST!
      resource_cat.noop = false
    }
  end
 
  def decorator?
    reference = @resource[:resource]

    # lookup the CURRENT state of the resource on the system
 
    # WTF is this not needed?
    #resource_key = [reference.type, reference.name].join('/')
    resource_key = reference.name
    resource_now = Puppet::Resource.indirection.find(resource_key)
    resource_now_ensure = resource_now.to_data_hash["parameters"][:ensure]
    resource_now_hash = resource_now.to_data_hash["parameters"]

    fire = false

    # lookup the DESIRED state of the resource in the catalog
    res = Puppet::Resource.new(reference)
    reference.catalog = resource.catalog
    resource_cat = reference.catalog.resource(res.to_s)
    if resource_cat == nil
      fail("reference #{resource_key} was not found in the catalog")
    end  
  
    # process each of the resource's properties (actions)
    resource_cat.properties.any? do |property|

      # lookup what the corresponing property *is* right now on the system
      # using the data from the first lookup
      is = resource_now_hash[property.name]
      if property.should && !property.safe_insync?(is)
        # Puppet needs to do something to uplift this resource so we will fire!
        fire = true
      end
    end
    
    # return
    fire
  end

end
