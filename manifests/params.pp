class pe_failover::params {
  $rsync_user           = 'pe-puppet'
  $rsync_user_ssh_id    = '/opt/puppetlabs/server/data/puppetserver/.ssh/puppet_ca_id_rsa'
  $rsync_ssl_dir        = '/etc/puppetlabs/puppet/ssl/ca/'
  $rsync_command        = 'rsync -au --delete'
  $incron_ssl_condition = '/etc/puppetlabs/puppet/ssl/ca/signed IN_CREATE,IN_DELETE,IN_MODIFY'
  $pe_failover_directory     = '/opt/pe_failover'
  $script_directory     = '/opt/pe_failover/scripts'

  #Values used for pgsql dump & restore...
  $pg_bin_directory         = '/opt/puppetlabs/server/bin'
  $dump_path                = "${pe_failover_directory}/dumps"
  $pg_dump_command          = "/usr/bin/sudo -u pe-postgres ${pg_bin_directory}/pg_dump -C -Fc"
  $timestamp_command        = '`/bin/date +"%Y-%m-%d-%H%M"`'
  $hour                     = '*'
  $minute                   = '*/15'
  $monthday                 = '*'

  $pe_users = {
    'pe-postgres'               =>
        {
          'description' => 'Puppet Enterprise PostgreSQL Server',
          'home'        => '/opt/puppetlabs/server/data/postgresql',
          'shell'       => '/sbin/nologin',
        },
    'pe-orchestration-services' =>
        {
          'description' => 'pe-orchestration-services daemon',
          'home'        => '/opt/puppetlabs/server/data/orchestration-services',
          'shell'       => '/sbin/nologin',
        },
    'pe-console-services'       =>
        {
          'description' => 'pe-console-services daemon',
          'home'        => '/opt/puppetlabs/server/data/console-services',
          'shell'       => '/sbin/nologin',
        },
    'pe-puppetdb'               =>
        {
          'description' => 'pe-puppetdb daemon',
          'home'        => '/opt/puppetlabs/server/data/puppetdb',
          'shell'       => '/sbin/nologin',
        },
    'pe-puppet'                =>
        {
          'description' => 'pe-puppetserver daemon',
          'home'        => '/opt/puppetlabs/server/data/puppetserver',
          'shell'       => '/sbin/nologin',
        },
    'pe-webserver'             =>
        {
          'description' => 'Puppet Enterprise Webserver User',
          'home'        => '/var/cache/puppetlabs/nginx',
          'shell'       => '/sbin/nologin',
        },
    'pe-activemq'              =>
        {
          'description' => 'Puppet Enterprise Apache Activemq',
          'home'        => '/opt/puppetlabs/server/data/activemq',
          'shell'       => '/sbin/nologin',
        },
    }
}
