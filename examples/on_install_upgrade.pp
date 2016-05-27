decorator { "testing123":
  resource   => Package['nmap-ncat'],
  before_refresh => Exec["boom"],
}


package { "nmap-ncat":
  ensure => present,
  #ensure => "1.2.4",
}


exec { "boom":
  noop => true,
  command => '/bin/date > /tmp/log.txt',
  before => Package["nmap-ncat"],
}
