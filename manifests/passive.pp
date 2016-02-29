class pe_failover::passive (
  String $auth_key,
) inherits pe_failover::params{

  include ::pe_failover::passive::paths
  include ::pe_failover::passive::users
  include ::pe_failover::passive::ssh
  include ::pe_failover::passive::scripts
  include ::pe_failover::passive::cron
  include ::pe_failover::passive::incron

}
