class pe_failover::passive (
  String $auth_key,
  String $rsync_user                   = $pe_failover::params::rsync_user,
  Hash $pe_users                       = $pe_failover::params::pe_users,
  String $pe_failover_directory        = $pe_failover::params::pe_failover_directory,
  String $script_directory             = $pe_failover::params::script_directory,
  String $dump_path                    = $pe_failover::params::dump_path,
  String $nc_dump_path                 = $pe_failover::params::nc_dump_path,
  String $restore_nc_minute            = $pe_failover::params::restore_nc_minute,
  String $restore_db_minute            = $pe_failover::params::restore_db_minute,
  String $restore_hour                 = $pe_failover::params::restore_hour,
  String $restore_monthday             = $pe_failover::params::restore_monthday,
  String $incron_passive_ssl_condition = $pe_failover::params::incron_passive_ssl_condition,
  Array $pe_bkup_dbs                   = $pe_failover::params::pe_bkup_dbs,
) inherits pe_failover::params{

  include ::pe_failover
  include ::pe_failover::passive::paths
  include ::pe_failover::passive::users
  include ::pe_failover::passive::ssh
  include ::pe_failover::passive::scripts
  include ::pe_failover::passive::cron
  include ::pe_failover::passive::incron

  Class['::pe_failover']
    -> Class['::pe_failover::passive::paths']
    -> Class['::pe_failover::passive::users']
    -> Class['::pe_failover::passive::ssh']
    -> Class['::pe_failover::passive::scripts']
    -> Class['::pe_failover::passive::cron']
    -> Class['::pe_failover::passive::incron']
}
