require 'puppet/application/resource'
Puppet::Type.type(:only_before_sync).provide(:ruby) do
  desc "Decorate a resource with a resource to run before refresh"


  def only_before_sync
    # Iterate all passed in resource references if we have been told to run
    @resource[:before_sync].any? { | res |    
      # turn off noop mode so the resource will run IN THE ORDER SPECIFIED
      # IN THE MANIFEST!
      res.noop = false
    }
  end
 
  def only_before_sync?
    reference = @resource[:resource]
    resource_key = [reference.type, reference.name].join('/')

    # lookup the CURRENT state of the resource on the system
    resource_now = Puppet::Resource.indirection.find(resource_key)
    resource_now_ensure = resource_now.to_data_hash["parameters"][:ensure]
    resource_now_hash = resource_now.to_data_hash["parameters"]
    fire = false

    # lookup the DESIRED state of the resource in the catalog
    res = Puppet::Resource.new(reference)
    reference.catalog = resource.catalog
    resource_cat = reference.catalog.resource(res.to_s)

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
