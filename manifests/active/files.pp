class pe_failover::active::files {

  # Set Vars for template
  $pe_failover_mode_var = 'active'
  $pe_failover_key_var  = ''
  $pe_failover_passive_master_var = $::pe_failover::active::passive_master

  file {"${::pe_failover::pe_failover_directory}/conf/pe_failover.yaml":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0660',
    content => template('pe_failover/pe_failover.yaml.erb'),
  }

}
