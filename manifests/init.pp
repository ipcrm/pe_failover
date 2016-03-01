class pe_failover (
  Array  $exclude_certs                = [],
  Array  $pe_bkup_dbs                  = $::pe_failover::params::pe_bkup_dbs,
  Hash   $pe_users                     = $::pe_failover::params::pe_users,
  String $pe_failover_directory        = $::pe_failover::params::pe_failover_directory,
  String $script_directory             = $::pe_failover::params::script_directory,
  String $cert_dump_path               = $::pe_failover::params::cert_dump_path,
  String $dump_path                    = $::pe_failover::params::dump_path,
  String $nc_dump_path                 = $::pe_failover::params::nc_dump_path,
  String $hour                         = $::pe_failover::params::hour,
  String $incron_ssl_condition         = $::pe_failover::params::incron_ssl_condition,
  String $incron_passive_ssl_condition = $::pe_failover::params::incron_passive_ssl_condition,
  String $minute                       = $::pe_failover::params::minute,
  String $monthday                     = $::pe_failover::params::monthday,
  String $sync_minute                  = $::pe_failover::params::sync_minute,
  String $sync_hour                    = $::pe_failover::params::sync_hour,
  String $sync_monthday                = $::pe_failover::params::sync_monthday,
  String $restore_nc_minute            = $::pe_failover::params::restore_nc_minute,
  String $restore_db_minute            = $::pe_failover::params::restore_db_minute,
  String $restore_hour                 = $::pe_failover::params::restore_hour,
  String $restore_monthday             = $::pe_failover::params::restore_monthday,
  String $rsync_user                   = $::pe_failover::params::rsync_user,
  String $rsync_user_home              = $::pe_failover::params::rsync_user_home,
  String $rsync_user_ssh_id            = $::pe_failover::params::rsync_user_ssh_id,
  String $rsync_ssl_dir                = $::pe_failover::params::rsync_ssl_dir,
  String $rsync_command                = $::pe_failover::params::rsync_command,
) inherits pe_failover::params{

  # Ensure PE users area present - this will only imnpact the passive during initial setup
  $pe_users.keys.each |$pe_user| {
    user{$pe_user:
      comment    => $pe_users[$pe_user]['description'],
      home       => $pe_users[$pe_user]['home'],
      managehome => false,
      shell      => $pe_users[$pe_user]['shell'],
    }
  }

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

  file {"${pe_failover_directory}/conf":
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0770',
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
