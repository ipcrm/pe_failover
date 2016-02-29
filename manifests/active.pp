class pe_failover::active (
  String $passive_master,
) inherits pe_failover::params {

  include ::pe_failover::active::ssh
  include ::pe_failover::active::db
  include ::pe_failover::active::scripts
  include ::pe_failover::active::cron
  include ::pe_failover::active::incron

}
