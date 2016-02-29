class pe_failover::active (
  String $passive_master,
  Array $exclude_certs          = [],
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
  String $cert_dump_path        = $pe_failover::params::cert_dump_path,
) inherits pe_failover::params {

  include ::pe_failover
  include ::pe_failover::active::ssh
  include ::pe_failover::active::db
  include ::pe_failover::active::scripts
  include ::pe_failover::active::cron
  include ::pe_failover::active::incron

  Class['::pe_failover']
    -> Class['::pe_failover::active::ssh']
    -> Class['::pe_failover::active::db']
    -> Class['::pe_failover::active::scripts']
    -> Class['::pe_failover::active::cron']
    -> Class['::pe_failover::active::incron']
}
