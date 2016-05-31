require 'puppet/application/resource'
Puppet::Type.type(:only_before_sync).provide(:ruby) do
  desc "Decorate a resource with a resource to run before refresh"


  def only_before_sync
    # Iterate all passed in resource references if we have been told to run
    @resource[:before_sync].any? { | reference |    
      # fetch the catalogue representation for each resource ref

      puts reference.noop 
      puts "XXXXXXXXXXX"


      resource_key = [reference.type, reference.name].join('/')
#      resource_now = Puppet::Resource.indirection.find(resource_key)
  
#     res = Puppet::Resource.new(resource_key)
#      reference.catalog = resource.catalog
#      resource_cat = reference.catalog.resource(res.to_s)

      # turn off noop mode so the resource will run IN THE ORDER SPECIFIED
      # IN THE MANIFEST!
#      resource_cat.noop = false
      reference.noop = false
    }
  end
 
  def only_before_sync?
    reference = @resource[:resource]
        puts @resource[:resource].class.name


    catalog_resource = @resource[:resource]
    name = catalog_resource.name
    type = catalog_resource.type


    # lookup the CURRENT state of the resource on the system
 
    # WTF is this not needed?
    resource_key = [reference.type, reference.name].join('/')


    resource_now = Puppet::Resource.indirection.find(resource_key)
    resource_now_ensure = resource_now.to_data_hash["parameters"][:ensure]
    resource_now_hash = resource_now.to_data_hash["parameters"]
    fire = false

    # lookup the DESIRED state of the resource in the catalog
    res = Puppet::Resource.new(reference)
    reference.catalog = resource.catalog
    resource_cat = reference.catalog.resource(res.to_s)
  puts "MARK_A"
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
puts "LEAVING PREHCEK"    
    # return
    fire
  end

end
