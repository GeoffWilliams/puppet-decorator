decorator { "testing123":
  resource   => Package['nmap-ncat.x86_64'],
  before_refresh => Exec["boom"],
}


package { "nmap-ncat.x86_64":
  ensure => latest,
}


exec { "boom":
  refreshonly => true,                                          # the exec only fires when it receives a refresh from package
  command => '/bin/date > /tmp/log.txt'
}
