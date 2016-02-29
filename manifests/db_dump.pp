# Dump a PE database with a cron job and a script.
define pe_failover::db_dump (
  $db_name           = $title,
  $pg_dump_command   = $::pe_failover::params::pg_dump_command,
  $dump_path         = $::pe_failover::params::dump_path,
  $script_directory  = $::pe_failover::params::script_directory,
  $minute            = $::pe_failover::params::minute,
  $hour              = $::pe_failover::params::hour,
  $monthday          = $::pe_failover::params::monthday,
  $timestamp_command = $::pe_failover::params::timestamp_command,
  $md5sum_command    = $::pe_failover::params::md5sum_command,
  $rsync_user        = $::pe_failover::params::rsync_user,
) {

  validate_string($pg_dump_command)
  validate_absolute_path($dump_path)
  validate_absolute_path($script_directory)
  validate_string($minute)
  validate_string($hour)
  validate_string($monthday)

  file { "${script_directory}/dump_${db_name}.sh":
    ensure  => file,
    content => template('pe_failover/db_dump.sh.erb'),
    owner   => 'root',
    group   => '0',
    mode    => '0755',
    before  => Cron["${db_name}_db_dump"],
  }

  cron { "${db_name}_db_dump":
    ensure   => present,
    command  => "${script_directory}/dump_${db_name}.sh",
    user     => 'root',
    minute   => $minute,
    hour     => $hour,
    monthday => $monthday,
  }

}
