class pe_failover::passive (
  String $auth_key = $::pe_failover_key
) inherits pe_failover::params{

  if $auth_key == '' {
    fail('Auth_key not set and fact pe_failover_key is empty! Must set pe_failover_key in /opt/puppetlabs/facter/facts.d/pe_failover.yaml!')
  }

  require ::pe_failover
  contain ::pe_failover::passive::files
  contain ::pe_failover::passive::ssh
  contain ::pe_failover::passive::scripts
  contain ::pe_failover::passive::cron
  contain ::pe_failover::passive::incron

}
