class pe_failover::passive::incron {

  # Setup CA Update Incron process
  service { 'incrond':
    ensure    => running,
    enable    => true,
    subscribe => [
      File['/etc/incron.d/update_passive_ca_certs'],
      File['/etc/incron.d/sync_certs'],
    ],
  }

  file { '/etc/incron.d/update_passive_ca_certs':
    ensure  => file,
    mode    => '0744',
    content => "${::pe_failover::incron_passive_ssl_condition} ${::pe_failover::script_directory}/update_passive_ca.sh",
    require => Package['incron'],
  }

  # Remove the sync_certs process
  file{'/etc/incron.d/sync_certs': ensure => absent, }

}
