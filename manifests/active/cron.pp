class pe_failover::active::cron {
  # Create Cron job to regularly dump NC content
  cron { 'nc_dump':
    ensure   => present,
    command  => "${pe_failover::active::script_directory}/nc_dump.sh",
    user     => 'root',
    minute   => $pe_failover::active::minute,
    hour     => $pe_failover::active::hour,
    monthday => $pe_failover::active::monthday,
  }

  # Create the NC Dump Sync cron job
  cron { 'nc_sync':
    ensure   => present,
    command  => "${pe_failover::active::script_directory}/sync_nc_dumps.sh",
    user     => 'root',
    minute   => $pe_failover::active::sync_minute,
    hour     => $pe_failover::active::sync_hour,
    monthday => $pe_failover::active::sync_monthday,
  }


  # Create the DB Sync cron job
  cron { 'db_sync':
    ensure   => present,
    command  => "${pe_failover::active::script_directory}/sync_dbs.sh",
    user     => 'root',
    minute   => $pe_failover::active::sync_minute,
    hour     => $pe_failover::active::sync_hour,
    monthday => $pe_failover::active::sync_monthday,
  }

  # This next section handles removing resources that would have been setup
  # if this host was previously configured as a passive.  All we need to do
  # is make sure no restore processes run
  cron { 'rest_dbs_cron': ensure => absent, }
  cron { 'rest_nc_cron': ensure => absent, }

}
