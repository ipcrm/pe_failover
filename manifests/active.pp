class pe_failover::active (
  String $passive_master = $::pe_failover_passive_master,
  String $pdb_peer       = $::pe_failover_pdb_peer
) inherits pe_failover::params {

  if $passive_master == '' {
    fail('Parameter passive_master not set and fact pe_failover_passive_master is empty! Must set pe_failover_passive_master in /opt/puppetlabs/facter/facts.d/pe_failover.yaml!')
  }

  require ::pe_failover
  contain ::pe_failover::active::ssh
  contain ::pe_failover::active::db
  contain ::pe_failover::active::scripts
  contain ::pe_failover::active::cron
  contain ::pe_failover::active::incron
  contain ::pe_failover::active::files
  contain ::pe_failover::active::classification

  # If PDB Peer is set, enable PDB Replication
  if !empty($pdb_peer) {
    class {'::pe_failover::pdb_replication':
      pdb_peer => $pdb_peer,
    }
  }

}
