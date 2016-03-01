class pe_failover::active::files {

  # Set Vars for template
  $pe_failover_mode_var = 'active'
  $pe_failover_key_var  = ''

  file {"${::pe_failover::pe_failover_directory}/conf/pe_failover.yaml":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0770',
    content => template('pe_failover/pe_failover.yaml.erb'),
  }

}
