package { "nmap-ncat":
  ensure => present,
}

exec { "boom":
  noop    => true,
  command => '/bin/date > /tmp/log.txt',
}

# implies `before` on exec resource
only_before_sync { "testing123":
  resource    => Package['nmap-ncat'],
  before_sync => [
    Exec["boom"], 
    Exec["boom2"] 
  ],
}

exec { "boom2":
  noop    => true,
  command => "/bin/uname >> /tmp/log.txt",
}
