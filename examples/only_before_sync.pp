
# The package to install that we will attach our exec resources to
# notice that it is before all other resources even though it needs
# to be processed internally _last_.  The type and provider will 
# reorder the graph at compile time to take care of this
package { "nmap-ncat":
  ensure => present,
}


# Query RPM to verify that the package is not installed yet.  This
# proves that the package resource has not yet been processed
exec { "before_package_installed":
  noop    => true,
  command => '/bin/rpm -q nmap-ncat > /tmp/exec.txt',
  returns => 1,
}

# Make our 2 exec resources run before package installation only
# if an upgrade/install is happening.  You can add multiple resources
# by using an array.  All resources *MUST* be marked as noop in your
# puppet code.  The provider works by turning off noop mode for the 
# resource if a sync is required
only_before_sync { "testing123":
  resource    => Package['nmap-ncat'],
  before_sync => [
    Exec["before_package_installed"], 
    Exec["demo"] 
  ],
}

exec { "demo":
  noop    => true,
  command => "/bin/date > /tmp/demo.txt",
}
