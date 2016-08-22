class pe_failover::passive::scripts {

  # Vars for templates
  $dump_path         = $::pe_failover::dump_path
  $nc_dump_path      = $::pe_failover::nc_dump_path
  $cert_dump_path    = $::pe_failover::cert_dump_path
  $md5sum_command    = $::pe_failover::md5sum_command
  $timestamp_command = $::pe_failover::timestamp_command
  $rsync_command     = $::pe_failover::rsync_command
  $rsync_ssl_dir     = $::pe_failover::rsync_ssl_dir

  # Install the NCIO command
  package{'ncio':
    ensure   => present,
    provider => 'puppet_gem',
  }

  # Create DB Restore Script
  file { 'db_rest_script':
    ensure  => file,
    path    => "${::pe_failover::script_directory}/restore_dbs.sh",
    mode    => '0755',
    content => template('pe_failover/restore_dbs.sh.erb'),
  }

  # Create NC Restore Script
  file { 'nc_rest_script':
    ensure  => file,
    path    => "${::pe_failover::script_directory}/restore_nc.sh",
    mode    => '0755',
    content => template('pe_failover/restore_nc.sh.erb'),
  }

  # Create CA Update Script
  file { 'ca_update_script':
    ensure  => file,
    path    => "${::pe_failover::script_directory}/update_passive_ca.sh",
    mode    => '0755',
    content => template('pe_failover/update_passive_ca.sh.erb'),
  }

  # In the event this master is demoted from active to passive, update perms as required
  $::pe_failover::pe_bkup_dbs.each |$db| {
    file {"${::pe_failover::dump_path}/${db}/${db}_latest.psql":
      owner => $::pe_failover::rsync_user,
      group => $::pe_failover::rsync_user,
    }
    file {"${::pe_failover::dump_path}/${db}/${db}_latest.psql.md5sum":
      owner => $::pe_failover::rsync_user,
      group => $::pe_failover::rsync_user,
    }
  }

  # NC Dumps
  file {"${::pe_failover::nc_dump_path}/nc_dump.latest.json":
      owner => $::pe_failover::rsync_user,
      group => $::pe_failover::rsync_user,
  }



}
