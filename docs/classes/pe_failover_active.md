### Class: `pe_failover::active`
This class is used to configure the active master.  All required configurations are setup including users, ssh, scripts, cron jobs, incron, pe_failover paths.

The following private classes are included to perform the configuration:

|Class|
|---|
|[pe_failover::active::ssh](/manifests/active/ssh.pp)|
|[pe_failover::active::db](/manifests/active/db.pp)|
|[pe_failover::active::scripts](/manifests/active/scripts.pp)|
|[pe_failover::active::cron](/manifests/active/cron.pp)|
|[pe_failover::active::incron](/manifests/active/incron.pp)|

#### Parameters
##### `passive_master`
String. Required.  The full fqdn of the passive master.

##### `exclude_certs`
Array. This parameter gives you the ability to add excluded certificates from the CA update process.  Where this is useful is if your passive master is not just 1 server, but rather a group of compile master plus a monolithic master.  Default: _[]_

#### `rsync_user`
String. The user used to perform rsync transfers.  This user is managed by pe_failover.  Default _pe-transfer_

##### `rsync_user_home`
String. Home path for the `rsync_user`.  Default: _/home/pe-transfer_

##### `rsync_user_ssh_id`
String.  The path of the ssh_id file to be used for rsync transfers.  Default: _/home/pe-transfer/.ssh/pe_failover_id_rsa_

##### `rsync_ssl_dir`
String.  The path to the CA directory to be transferring to the passive master. Default: _/etc/puppetlabs/puppet/ssl/ca/_

##### `rsync_command`
String.  The rsync command to run along with base options.  Default _'rsync -au --delete'_

##### `incron_ssl_condition`
String. The inotify conditions on which the CA dir is synced to the passive master.  Default: _/etc/puppetlabs/puppet/ssl/ca/signed IN_CLOSE_WRITE,IN_DELETE_

##### `script_directory`
String.  The path to where script files should be written.  Default: _/opt/pe_failover/scripts_

##### `pe_failover_directory`
String.  The base path for all of the failover contents.  Default: _/opt/pe_failover_

##### `pe_bkup_dbs`
Array.  The array of databases that should be backed up.  Default: _['pe-rbac']_

##### `minute`
String.  Minute of the hour to export database or nc data - used in cron job.  Default: _10_

##### `hour`
String.  Hour of the day to export databases or nc data - used in cron job.  Default: _*_

##### `monthday`
String.  Monthday to export databases or nc data - used in cron job.  Default: _*_

##### `sync_minute`
String.  Minute of the hour to sync data to passive - used in cron job.  Default: _20_

##### `sync_hour`
String.  Hour of the day to sync to passive - used in cron job.  Default: _*_

##### `sync_monthday`
String.  Monthday to sync to passive - used in cron job.  Default: _*_

##### `dump_path`
String.  Path to export database backups to.  Default: _/opt/pe_failover/dumps_

##### `nc_dump_path`
String.  Path to export node classifier exports to.  Default: _/opt/pe_failover/nc_dumps_

##### `cert_dump_path`
String.  Path to rsync CA contents to on the passvie.  Default: _/opt/pe_failover/cert_dumps_

