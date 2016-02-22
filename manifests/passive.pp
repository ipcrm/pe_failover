class pe_failover::passive (
  String $auth_key = $::pe_failover_ha_key,
  Hash $pe_users = $::pe_ha_failover::params::pe_users
) inherits pe_failover::params{

  # Setup PE Users
  $pe_users.each |$pe_user| {
    user{$pe_user:
      comment    => $pe_users[$pe_user]['description'],
      home       => $pe_users[$pe_user]['home'],
      managehome => false,
      shell      => $pe_users[$pe_user]['shell'],
    }
  }

  # Create Required Home Dirs
  $pe_home_dirs = [
    '/opt/puppetlabs/server',
    '/opt/puppetlabs/server/data',
  ]

  file{$pe_home_dirs:
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }

  file{'pe-puppet home dir':
    ensure  => directory,
    path    => '/opt/puppetlabs/server/data/puppetserver',
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    mode    => '0755',
    require => File[$pe_home_dirs],
  }

  # Setup auth keys
  if $auth_key != '' {
    ssh_authorized_key{'pe-puppet@primarymaster':
      user    => 'pe-puppet',
      type    => 'ssh-rsa',
      key     => $auth_key,
      require => File['pe-puppet home dir'],
    }
  }else{
    fail('There is no value for auth_key parameter!')
  }

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
