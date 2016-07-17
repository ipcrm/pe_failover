class pe_failover::pdb_replication (
  $pdb_peer,
  $sync_interval  = '2m',
  $confdir        = $puppet_enterprise::params::puppetdb_confdir,
  $cert_whitelist = '/etc/puppetlabs/puppetdb/certificate-whitelist',
){

  if defined(Class['Puppet_enterprise']){
    # Most of this class is derived from puppet_enterprise::puppetdb::sync_ini
    Pe_ini_setting {
      ensure  => present,
      path    => "${confdir}/sync.ini",
      section => 'sync',
      require => File["${confdir}/sync.ini"],
      notify  => Service['pe-puppetdb'],
    }

    file { "${confdir}/sync.ini":
      ensure  => present,
      owner   => 'pe-puppetdb',
      group   => 'pe-puppetdb',
      mode    => '0640',
      require => Package['pe-puppetdb'],
    }

    pe_ini_setting {'puppetdb_sync_server_urls':
      setting => 'server_urls',
      value   => "https://${pdb_peer}:8081",
    }

    pe_ini_setting {'puppetdb_sync_intervals':
      setting => 'intervals',
      value   => $sync_interval,
    }

    puppet_enterprise::certs::whitelist_entry { "pdb_whitelist entry: ${pdb_peer}":
      certname => $pdb_peer,
      target   => $cert_whitelist,
      notify   => Service['pe-puppetdb'],
      require  => Class['puppet_enterprise::profile::puppetdb'],
    }

  }

}
