class pe_failover::active::classification {

  package{'puppetclassify':
    ensure   => present,
    provider => 'puppet_gem',
    notify   => Exec['refresh_classes'],
  }

  # Refresh classes in the NC prior to trying to create groups
  exec{'refesh_classes':
    command     => "${::pe_failover::script_directory}/refresh_classes.sh",
    refreshonly => true,
    require     => File["${::pe_failover::script_directory}/refresh_classes.sh"],
  }

  node_group { 'pe_failover':
    ensure               => 'present',
    environment          => 'production',
    override_environment => false,
    parent               => 'All Nodes',
    classes              => {'pe_failover' => {}},
    rule                 => ['and', ['~', ['fact', 'pe_failover_mode'], '(active|passive)']],
    require              => Package['puppetclassify'],
  }

  node_group { 'pe_failover-active':
    ensure               => 'present',
    classes              => {'pe_failover::active' => {}},
    environment          => 'production',
    override_environment => false,
    parent               => 'All Nodes',
    rule                 => ['and', ['~', ['fact', 'pe_failover_mode'], 'active']],
    require              => Node_group['pe_failover'],
  }

  node_group { 'pe_failover-passive':
    ensure               => 'present',
    classes              => {'pe_failover::passive' => {}},
    environment          => 'production',
    override_environment => false,
    parent               => 'All Nodes',
    rule                 => ['and', ['~', ['fact', 'pe_failover_mode'], 'passive']],
    require              => Node_group['pe_failover'],
  }
}
