class pe_failover::active (
  String $passive_master = $::pe_failover_passive_master
) inherits pe_failover::params {

  if $passive_master == '' {
    fail('Parameter passive_master not set and fact pe_failover_passive_master is empty! Must supply passive fqdn!')
  }

  require ::pe_failover
  contain ::pe_failover::active::ssh
  contain ::pe_failover::active::db
  contain ::pe_failover::active::scripts
  contain ::pe_failover::active::cron
  contain ::pe_failover::active::incron
  contain ::pe_failover::active::files

}
