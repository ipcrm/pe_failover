class pe_failover::passive::paths {

  # Create Required CA directories
  $pe_dirs = [
    '/etc/puppetlabs',
    '/etc/puppetlabs/puppet',
  ]

  file{$pe_dirs:
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }

  file{'/etc/puppetlabs/puppet/ssl':
    ensure => directory,
    owner  => 'pe-puppet',
    group  => 'pe-puppet',
    mode   => '0771',
  }

  file{'/etc/puppetlabs/puppet/ssl/ca':
    ensure => directory,
    owner  => 'pe-puppet',
    group  => 'pe-puppet',
    mode   => '0751',
  }

}
