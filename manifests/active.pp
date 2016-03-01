class pe_failover::active (
  String $passive_master,
) inherits pe_failover::params {

  require ::pe_failover
  contain ::pe_failover::active::ssh
  contain ::pe_failover::active::db
  contain ::pe_failover::active::scripts
  contain ::pe_failover::active::cron
  contain ::pe_failover::active::incron
  contain ::pe_failover::active::files

}
