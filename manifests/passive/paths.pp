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

}
