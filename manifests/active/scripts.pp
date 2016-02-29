class pe_failover::scripts {

  # Vars for templates
  $dump_path         = $::pe_failover::dump_path
  $nc_dump_path      = $::pe_failover::nc_dump_path
  $cert_dump_path    = $::pe_failover::cert_dump_path
  $md5sum_command    = $::pe_failover::md5sum_command
  $timestamp_command = $::pe_failover::timestamp_command
  $rsync_command     = $::pe_failover::rsync_command
  $rsync_ssl_dir     = $::pe_failover::rsync_ssl_dir
  $rsync_user_ssh_id = $::pe_failover::rsync_user_ssh_id
  $rsync_user        = $::pe_failover::rsync_user
  $passive_master    = $::pe_failover::active::passive_master

  # Populate merged cert exclude list for CA transfers
  $merged_exclude_certs = concat($pe_failover::exclude_certs, $pe_failover::active::passive_master)

  # Create a exclude file for rsync to use (and transfer to the passive for the same purpose)
  file {"${pe_failover::rsync_ssl_dir}/rsync_exclude":
    ensure  => present,
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    content => template('pe_failover/rsync_exclude.erb'),
  }

  # Create Script for the NC dump process
  file { 'nc_dump_script':
    ensure  => file,
    path    => "${pe_failover::script_directory}/nc_dump.sh",
    mode    => '0755',
    content => template('pe_failover/nc_dump.sh.erb'),
  }

  # Setup sync scripts for NC Dump sync
  file { 'sync_nc_dumps':
    ensure  => file,
    path    => "${pe_failover::script_directory}/sync_nc_dumps.sh",
    mode    => '0755',
    content => template('pe_failover/sync_nc_dumps.sh.erb'),
  }

  # Setup sync scripts for the DB sync cron job
  file { 'sync_db_script':
    ensure  => file,
    path    => "${pe_failover::script_directory}/sync_dbs.sh",
    mode    => '0755',
    content => template('pe_failover/sync_dbs.sh.erb'),
  }

  # Setup sync scripts for Incron Cert Sync process
  file { 'sync_script':
    ensure  => file,
    path    => "${pe_failover::script_directory}/sync_certs.sh",
    mode    => '0755',
    content => template('pe_failover/sync_certs.sh.erb'),
  }


}
