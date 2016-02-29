class pe_failover (
  String $pe_failover_directory = $pe_failover::params::pe_failover_directory,
  String $script_directory      = $pe_failover::params::script_directory,
  String $dump_path             = $pe_failover::params::dump_path,
  String $nc_dump_path          = $pe_failover::params::nc_dump_path,
  String $cert_dump_path        = $pe_failover::params::cert_dump_path,
  String $rsync_user            = $pe_failover::params::rsync_user,
  String $rsync_user_home       = $pe_failover::params::rsync_user_home,
  Array $pe_bkup_dbs            = $pe_failover::params::pe_bkup_dbs,
) inherits pe_failover::params{
  # Setup transfer user 
  user {$rsync_user:
    ensure     => present,
    managehome => true,
    home       => $rsync_user_home,
  }

  # Setup Common Paths
  file { [$pe_failover_directory, $script_directory]:
    ensure => directory,
    owner  => $rsync_user,
    group  => 'pe-postgres',
    mode   => '0775',
  }

  file { 'dump_directory':
      ensure => directory,
      path   => $dump_path,
      owner  => $rsync_user,
      group  => 'pe-postgres',
      mode   => '0770',
  }

  # Create DB Archive Locations
  $pe_bkup_dbs.each |$db| {
    file{["${dump_path}/${db}", "${dump_path}/${db}/archive"]:
      ensure => directory,
      owner  => $rsync_user,
      group  => 'pe-postgres',
      mode   => '0775',
    }
  }

  file { 'nc_dump_directory':
      ensure => directory,
      path   => $nc_dump_path,
      owner  => $rsync_user,
      group  => 'pe-postgres',
      mode   => '0770',
  }

  file { 'nc_dump_directory_archive':
      ensure => directory,
      path   => "${nc_dump_path}/archive",
      owner  => $rsync_user,
      group  => 'pe-postgres',
      mode   => '0770',
  }

  file { 'cert_dump_directory':
      ensure => directory,
      path   => $cert_dump_path,
      owner  => $rsync_user,
      group  => 'pe-puppet',
      mode   => '0770',
  }

  file { 'cert_dump_directory_archive':
      ensure => directory,
      path   => "${cert_dump_path}/archive",
      owner  => $rsync_user,
      group  => 'pe-puppet',
      mode   => '0770',
  }

  # Manage incrond and scripts that send certs to the passive master when any
  # changes are made, e.g. for new agents, revoked certs, etc...
  ensure_packages(['rsync','incron'])
}
