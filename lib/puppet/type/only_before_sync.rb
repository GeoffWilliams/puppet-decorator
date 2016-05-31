Puppet::Type.newtype(:only_before_sync) do
  @doc = "Support for running resources before a resource that will sync"

  newproperty(:enable) do
    desc "Enable this resource"
    newvalues :true, :false
    defaultto :true

    def sync
      @resource.provider.only_before_sync
    end

    def retrieve
      @resource["enable"]
    end

    def insync?(is)
      case @resource["enable"]
      when :true
        # If a transition should occur, the resource is not insync.
        !@resource.provider.only_before_sync?
      else
        # Return true, since a disabled transition is always insync.
        true
      end
    end
  end

  newparam(:before_sync, :array_matching => :all) do
    desc "Reference to resource to process before refresh"   
    munge do |values|
      values = [values] unless values.is_a? Array
      values
    end
  end

  # after refresh is not needed, just do notify or subscribe
  
  newparam(:resource) do
    desc "Resource to decorate"
  end
  
  newparam(:name) do
    desc "Name used for reference purposes only"
  end
  
  validate do
    [:resource, :before_sync].each do |param|
      if not self.parameters[param]
        self.fail "Required parameter missing: #{param}"
      end
    end
  end


  # This type needs to implement an "autobefore" kind of behavior. Currently
  # the Puppet type system only supports autorequire, so we achieve autobefore
  # by hijacking autorequire.
  def autorequire(rel_catalog = nil)
    reqs = super

    # THIS resource before the resource we are working against and all of 
    # the resources we will conditionally run
    [ 
      @parameters[:resource].value, @parameters[:before_sync].value 
    ].flatten.each do | rel |    

        reqs << Puppet::Relationship::new(self, catalog.resource(rel.to_s))
    end

    # before_sync resources before the resource we are working on
    @parameters[:before_sync].value.flatten.each do |rel|
      reqs << Puppet::Relationship::new(
        catalog.resource(rel.to_s),
        catalog.resource(@parameters[:resource].value.to_s),
      )
    end

    reqs
  end

  def pre_run_check
    # resource parameter must exist in catalog and replace value with resolved
    # catalogue entity.  THE REPLACEMENT IS IMPORTANT! otherwise in APPLY mode
    # you end up with a string instead of a catalogue reference
    resource = parameter(:resource)
    resource.value = retrieve_resource_reference(resource.value)

    # before_sync resources *MUST* specify noop in catalog
    # Validate and munge `prior_to`
    before_sync = parameter(:before_sync)

    before_sync.value.map! do |res|
      begin
        retrieve_resource_reference(res)
      rescue ArgumentError => err
        self.fail "Parameter prior_to failed: #{err} at #{@file}:#{@line}"
      end
    end
    before_sync.value.each do | res |
      if not res.noop?
        self.fail "#{res} must be in noop mode to use only_before_sync resource"
      end
    end
    #before_sync.each do |res|
    #  res.value = 
    #  #resolved = retrieve_resource_reference(res)
    #  if not resolved.noop?
    #    self.fail "#{resolved} must be in noop mode to use only_before_sync resource"
    #  else
    #   # res.value = resolved
    #  end
    #end


  end

  # Retrieves a resourcereference from the catalog.
  #
  # @raise [ArgumentError] if the object is not a valid resource
  #   reference or does not exist in the catalog.
  # @return [void]
  def retrieve_resource_reference(res)
    Puppet::Resource.new(res)
    resource = catalog.resource(res.to_s)
    raise ArgumentError, "#{res} is not in the catalog" unless resource
    resource
  end

end
