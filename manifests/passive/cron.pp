class pe_failover::passive::cron {

  # Create the cron job to rest all present db dumps
  cron { 'rest_dbs_cron':
    ensure   => present,
    command  => "${::pe_failover::passive::script_directory}/restore_dbs.sh",
    user     => 'root',
    minute   => $::pe_failover::passive::restore_db_minute,
    hour     => $::pe_failover::passive::restore_hour,
    monthday => $::pe_failover::passive::restore_monthday,
  }

  # Create the cron job to rest all present db dumps
  cron { 'rest_nc_cron':
    ensure   => present,
    command  => "${::pe_failover::passive::script_directory}/restore_nc.sh",
    user     => 'root',
    minute   => $::pe_failover::passive::restore_nc_minute,
    hour     => $::pe_failover::passive::restore_hour,
    monthday => $::pe_failover::passive::restore_monthday,
  }

  # In the event this host was demoted, cleanup jobs from active
  # Remove cron jobs used by active master
  cron { 'nc_dump': ensure => absent, }
  cron { 'nc_sync': ensure => absent, }
  cron { 'db_sync': ensure => absent, }

  $::pe_failover::passive::pe_bkup_dbs.each |$db| {
    cron { "${db}_db_dump": ensure => absent, }
  }

}
