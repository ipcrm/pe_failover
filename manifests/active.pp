class pe_failover::active (
  String $passive_master,
  String $rsync_user        = $pe_failover::params::rsync_user,
  String $rsync_user_ssh_id = $pe_failover::params::rsync_user_ssh_id,
  String $rsync_ssl_dir     = $pe_failover::params::rsync_ssl_dir,
  String $rsync_command     = $pe_failover::params::rsync_command,
  $incron_ssl_condition     = $pe_failover::params::incron_ssl_condition,
  String $script_directory  = $pe_failover::params::script_directory,
  Array $pe_bkup_dbs        = ['pe-rbac','pe-classifier'],
  String $minute            = $pe_failover::params::minute,
  String $hour              = $pe_failover::params::hour,
  String $monthday          = $pe_failover::params::monthday,
  String $dump_path         = $pe_failover::params::dump_path,
) inherits pe_failover::params {

  # Manage incrond and scripts that send certs to the passive master when any
  # changes are made, e.g. for new agents, revoked certs, etc...
  ensure_packages(['rsync','incron'])

  file { $script_directory:
    ensure => directory,
    owner  => 'pe-puppet',
    group  => 'pe-puppet',
    mode   => '0750',
  }

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

  service { 'incrond':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/incron.d/sync_certs'],
  }

  file { 'dump_directory':
      path  => $dump_path,
      owner => 'pe-postgres',
      group => 'pe-puppet',
      mode  => '0770',
  }

  $pe_bkup_dbs.each |$db| {
    pe_failover::db_dump { $db:
      minute   => $minute,
      hour     => $hour,
      monthday => $monthday,
    }
  }

}
