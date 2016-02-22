class pe_failover::active (
  String $passive_master,
  String $rsync_user            = $pe_failover::params::rsync_user,
  String $rsync_user_ssh_id     = $pe_failover::params::rsync_user_ssh_id,
  String $rsync_ssl_dir         = $pe_failover::params::rsync_ssl_dir,
  String $rsync_command         = $pe_failover::params::rsync_command,
  String $incron_ssl_condition  = $pe_failover::params::incron_ssl_condition,
  String $incron_nc_condition   = $pe_failover::params::incron_nc_condition,
  String $script_directory      = $pe_failover::params::script_directory,
  String $pe_failover_directory = $pe_failover::params::pe_failover_directory,
  Array $pe_bkup_dbs            = ['pe-rbac'],
  String $minute                = $pe_failover::params::minute,
  String $hour                  = $pe_failover::params::hour,
  String $monthday              = $pe_failover::params::monthday,
  String $sync_minute           = $pe_failover::params::sync_minute,
  String $sync_hour             = $pe_failover::params::sync_hour,
  String $sync_monthday         = $pe_failover::params::sync_monthday,
  String $dump_path             = $pe_failover::params::dump_path,
  String $nc_dump_path          = $pe_failover::params::nc_dump_path,
) inherits pe_failover::params {

  # Manage incrond and scripts that send certs to the passive master when any
  # changes are made, e.g. for new agents, revoked certs, etc...
  ensure_packages(['rsync','incron'])

  file { 'sync_script':
    ensure  => file,
    path    => "${script_directory}/sync_certs.sh",
    mode    => '0750',
    content => template('pe_failover/sync_certs.sh.erb'),
  }

  file { '/etc/incron.d/sync_certs':
    ensure  => file,
    mode    => '0744',
    content => "${incron_ssl_condition} ${script_directory}/sync_certs.sh",
    require => Package['incron'],
  }

  file { 'sync_nc_dumps':
    ensure  => file,
    path    => "${script_directory}/sync_nc_dumps.sh",
    mode    => '0750',
    content => template('pe_failover/sync_nc_dumps.sh.erb'),
  }

  file { '/etc/incron.d/sync_nc_dumps':
    ensure  => file,
    mode    => '0744',
    content => "${incron_nc_condition} ${script_directory}/sync_nc_dumps.sh",
    require => Package['incron'],
  }

  service { 'incrond':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/incron.d/sync_certs'],
  }

  file { 'sync_db_script':
    ensure  => file,
    path    => "${script_directory}/sync_dbs.sh",
    mode    => '0750',
    content => template('pe_failover/sync_dbs.sh.erb'),
  }

  cron { 'db_sync':
    ensure   => present,
    command  => "${script_directory}/sync_dbs.sh",
    user     => 'root',
    minute   => $sync_minute,
    hour     => $sync_hour,
    monthday => $sync_monthday,
  }

  $pe_bkup_dbs.each |$db| {
    pe_failover::db_dump { $db:
      minute   => $minute,
      hour     => $hour,
      monthday => $monthday,
    }
  }

  file { 'nc_dump_script':
    ensure  => file,
    path    => "${script_directory}/nc_dump.sh",
    mode    => '0750',
    content => template('pe_failover/nc_dump.sh.erb'),
  }

  cron { 'nc_dump':
    ensure   => present,
    command  => "${script_directory}/nc_dump.sh",
    user     => 'root',
    minute   => $sync_minute,
    hour     => $sync_hour,
    monthday => $sync_monthday,
  }

}
