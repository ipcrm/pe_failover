class pe_failover::passive (
  String $auth_key,
) inherits pe_failover::params{

  require ::pe_failover
  contain ::pe_failover::passive::paths
  contain ::pe_failover::passive::users
  contain ::pe_failover::passive::ssh
  contain ::pe_failover::passive::scripts
  contain ::pe_failover::passive::cron
  contain ::pe_failover::passive::incron

}
