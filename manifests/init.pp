class pe_failover (
  String $pe_failover_directory = $pe_failover::params::pe_failover_directory,
  String $script_directory      = $pe_failover::params::script_directory,
  String $dump_path             = $pe_failover::params::dump_path,
  String $nc_dump_path          = $pe_failover::params::nc_dump_path,
) inherits pe_failover::params{

  file { [$pe_failover_directory, $script_directory]:
    ensure => directory,
    owner  => 'pe-puppet',
    group  => 'pe-puppet',
    mode   => '0775',
  }

  file { 'dump_directory':
      ensure => directory,
      path   => $dump_path,
      owner  => 'pe-postgres',
      group  => 'pe-puppet',
      mode   => '0770',
  }

  file { 'nc_dump_directory':
      ensure => directory,
      path   => $nc_dump_path,
      owner  => 'pe-puppet',
      group  => 'pe-puppet',
      mode   => '0770',
  }

}
