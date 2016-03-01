class pe_failover::active::cron {
  # Create Cron job to regularly dump NC content
  cron { 'nc_dump':
    ensure   => present,
    command  => "${pe_failover::script_directory}/nc_dump.sh",
    user     => 'root',
    minute   => $pe_failover::minute,
    hour     => $pe_failover::hour,
    monthday => $pe_failover::monthday,
  }

  # This next section handles removing resources that would have been setup
  # if this host was previously configured as a passive.  All we need to do
  # is make sure no restore processes run
  cron { 'rest_dbs_cron': ensure => absent, }
  cron { 'rest_nc_cron': ensure => absent, }

}
