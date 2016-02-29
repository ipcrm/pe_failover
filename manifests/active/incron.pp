class pe_failover::incron {
  # Setup incrond
  service { 'incrond':
    ensure    => running,
    enable    => true,
    subscribe => [
      File['/etc/incron.d/sync_certs'],
      File['/etc/incron.d/update_passive_ca_certs'],
    ],
  }

  file { '/etc/incron.d/sync_certs':
    ensure  => file,
    mode    => '0744',
    content => "${pe_failover::incron_ssl_condition} ${pe_failover::script_directory}/sync_certs.sh",
    require => Package['incron'],
  }

  # Remove passive incron configuration in the event this host has had its role changed
  file { '/etc/incron.d/update_passive_ca_certs': ensure => absent, }
}
