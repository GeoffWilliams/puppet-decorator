Puppet::Type.newtype(:decorator) do
  @doc = "decorate a resource"

  newproperty(:enable) do
    desc "Enable this decorator"
    newvalues :true, :false
    defaultto :true

    def sync
      @resource.provider.decorator
    end

    def retrieve
      @resource["enable"]
    end

    def insync?(is)
      case @resource["enable"]
      when :true
        # If a transition should occur, the resource is not insync.
        !@resource.provider.decorator?
      else
        # Return true, since a disabled transition is always insync.
        true
      end
    end
  end

  newparam(:before_refresh) do
    desc "Reference to resource to process before refresh"   
  end

  # after refresh is not needed, just do notify or subscribe
  
  newparam(:resource) do
    desc "Resource to decorate"
  end
  
  newparam(:name) do
    desc "Name used for reference purposes only"
  end
  
end
