class pe_failover::active::ssh {
  # Validate the proivded passive_master is safe to use with execs
  validate_re($pe_failover::active::passive_master, '\b([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}\b')

  # Create a new key for use with pe_failover
  exec{"create_ssh_key_for_${pe_failover::active::rsync_user}":
    command => "/bin/ssh-keygen -t rsa -N '' -f ${pe_failover::active::rsync_user_home}/.ssh/pe_failover_id_rsa",
    user    => $pe_failover::active::rsync_user,
    creates => "${pe_failover::active::rsync_user_home}/.ssh/pe_failover_id_rsa",
  }

  # Create Known hosts file if doesn't exist(rsync_user)
  file {"${pe_failover::active::rsync_user_home}/.ssh/known_hosts":
    ensure  => present,
    owner   => $pe_failover::active::rsync_user,
    group   => $pe_failover::active::rsync_user,
    mode    => '0644',
    require => Exec["create_ssh_key_for_${pe_failover::active::rsync_user}"],
  }

  # Add known host for our master
  exec{'passive_master_key':
    command => "/bin/ssh-keyscan -t rsa ${pe_failover::active::passive_master} >> ${pe_failover::active::rsync_user_home}/.ssh/known_hosts",
    unless  => "/bin/grep ${pe_failover::active::passive_master} ${pe_failover::active::rsync_user_home}/.ssh/known_hosts" ,
    require => File["${pe_failover::active::rsync_user_home}/.ssh/known_hosts"],
  }

  # Create Known hosts file if doesn't exist(root)
  file {'/root/.ssh':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  file {'/root/.ssh/known_hosts':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  # Add known host for our master
  exec{'root_passive_master_key':
    command => "/bin/ssh-keyscan -t rsa ${pe_failover::active::passive_master} >> /root/.ssh/known_hosts",
    unless  => "/bin/grep ${pe_failover::active::passive_master} /root/.ssh/known_hosts" ,
    require => File['/root/.ssh/known_hosts'],
  }
}
