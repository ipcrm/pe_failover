class pe_failover::active (
  String $passive_master,
  String $rsync_user            = $pe_failover::params::rsync_user,
  String $rsync_user_home       = $pe_failover::params::rsync_user_home,
  String $rsync_user_ssh_id     = $pe_failover::params::rsync_user_ssh_id,
  String $rsync_ssl_dir         = $pe_failover::params::rsync_ssl_dir,
  String $rsync_command         = $pe_failover::params::rsync_command,
  String $incron_ssl_condition  = $pe_failover::params::incron_ssl_condition,
  String $script_directory      = $pe_failover::params::script_directory,
  String $pe_failover_directory = $pe_failover::params::pe_failover_directory,
  Array $pe_bkup_dbs            = $pe_failover::params::pe_bkup_dbs,
  String $minute                = $pe_failover::params::minute,
  String $hour                  = $pe_failover::params::hour,
  String $monthday              = $pe_failover::params::monthday,
  String $sync_minute           = $pe_failover::params::sync_minute,
  String $sync_hour             = $pe_failover::params::sync_hour,
  String $sync_monthday         = $pe_failover::params::sync_monthday,
  String $dump_path             = $pe_failover::params::dump_path,
  String $nc_dump_path          = $pe_failover::params::nc_dump_path,
) inherits pe_failover::params {

  include ::pe_failover

  # Validate the proivded passive_master is safe to use with generate
  validate_re($passive_master, '\b([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}\b')

  # Create a new key for use with pe_failover
  exec{"create_ssh_key_for_${rsync_user}":
    command => "/bin/ssh-keygen -t rsa -N '' -f ${rsync_user_home}/.ssh/pe_failover_id_rsa",
    user    => $rsync_user,
    creates => "${rsync_user_home}/.ssh/pe_failover_id_rsa",
  }

  #Set appropriate perms for ssh ids
  file{"${rsync_user_home}/.ssh":
    owner   => $rsync_user,
    group   => $rsync_user,
    recurse => true,
  }

  # Create Known hosts file if doesn't exist
  file {"${rsync_user_home}/.ssh/known_hosts":
    ensure  => present,
    owner   => $rsync_user,
    group   => $rsync_user,
    mode    => '0644',
    require => Exec["create_ssh_key_for_${rsync_user}"],
  }

  # Add known host for our master
  exec{'passive_master_key':
    command => "/bin/ssh-keyscan -t rsa ${passive_master} >> ${rsync_user_home}/.ssh/known_hosts",
    unless  => "/bin/grep ${passive_master} ${rsync_user_home}/.ssh/known_hosts" ,
    require => File["${rsync_user_home}/.ssh/known_hosts"],
  }

  # Manage incrond and scripts that send certs to the passive master when any
  # changes are made, e.g. for new agents, revoked certs, etc...
  ensure_packages(['rsync','incron'])

  service { 'incrond':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/incron.d/sync_certs'],
  }

  # Setup sync scripts for Incron Cert Sync process
  file { 'sync_script':
    ensure  => file,
    path    => "${script_directory}/sync_certs.sh",
    mode    => '0755',
    content => template('pe_failover/sync_certs.sh.erb'),
  }

  file { '/etc/incron.d/sync_certs':
    ensure  => file,
    mode    => '0744',
    content => "${incron_ssl_condition} ${script_directory}/sync_certs.sh",
    require => Package['incron'],
  }

  # Create Script for the NC dump process
  file { 'nc_dump_script':
    ensure  => file,
    path    => "${script_directory}/nc_dump.sh",
    mode    => '0755',
    content => template('pe_failover/nc_dump.sh.erb'),
  }

  # Create Cron job to regularly dump NC content
  cron { 'nc_dump':
    ensure   => present,
    command  => "${script_directory}/nc_dump.sh",
    user     => 'root',
    minute   => $minute,
    hour     => $hour,
    monthday => $monthday,
  }

  # Setup sync scripts for NC Dump sync
  file { 'sync_nc_dumps':
    ensure  => file,
    path    => "${script_directory}/sync_nc_dumps.sh",
    mode    => '0755',
    content => template('pe_failover/sync_nc_dumps.sh.erb'),
  }

  # Create the NC Dump Sync cron job
  cron { 'nc_sync':
    ensure   => present,
    command  => "${script_directory}/sync_nc_dumps.sh",
    user     => $rsync_user,
    minute   => $sync_minute,
    hour     => $sync_hour,
    monthday => $sync_monthday,
  }


  # Setup sync scripts for the DB sync cron job
  file { 'sync_db_script':
    ensure  => file,
    path    => "${script_directory}/sync_dbs.sh",
    mode    => '0755',
    content => template('pe_failover/sync_dbs.sh.erb'),
  }

  # Create the DB Sync cron job
  cron { 'db_sync':
    ensure   => present,
    command  => "${script_directory}/sync_dbs.sh",
    user     => $rsync_user,
    minute   => $sync_minute,
    hour     => $sync_hour,
    monthday => $sync_monthday,
  }

  # Create dumps for each supplied database (pe-rbac ONLY by default)
  $pe_bkup_dbs.each |$db| {
    pe_failover::db_dump { $db:
      minute   => $minute,
      hour     => $hour,
      monthday => $monthday,
    }
  }


}
