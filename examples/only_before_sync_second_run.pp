# This file contains the same puppet code as only_before_sync.pp with
# the caveat that exec output is sent to different files to facilitate
# testing.

# this package should have been installed in the previous run
package { "nmap-ncat":
  ensure => present,
}


# this exec should not run at all
exec { "before_package_installed":
  noop    => true,
  command => '/bin/rpm -q nmap-ncat > /tmp/exec_second_run.txt',
  returns => 1,
}

only_before_sync { "testing123":
  resource    => Package['nmap-ncat'],
  before_sync => [
    Exec["before_package_installed"], 
    Exec["demo"] 
  ],
}

# this exec shouldn't run at all
exec { "demo":
  noop    => true,
  command => "/bin/date > /tmp/demo_second_run.txt",
}

# prove that this manifest was processed
exec { "second_puppet_run_completed":
  command => "/bin/touch /tmp/second_run_completed.txt",
}
