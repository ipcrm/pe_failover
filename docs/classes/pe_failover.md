### Class: `pe_failover`

Base class that sets up common users, packages, and directories.  Also, almost all params are stored centrally in this class and should be overriden here.

#### Parameters
##### `cert_dump_path`
String.  Path to rsync CA contents to on the passvie.  Default: _/opt/pe_failover/cert_dumps_

##### `dump_path`
String.  Path to export database backups to.  Default: _/opt/pe_failover/dumps_

##### `exclude_certs`
Array. This parameter gives you the ability to add excluded certificates from the CA update process.  Where this is useful is if your passive master is not just 1 server, but rather a group of compile master plus a monolithic master.  Default: _[]_

##### `hour`
String.  Hour of the day to export databases or nc data - used in cron job.  Default: _*_

##### `incron_passive_ssl_condition`


##### `incron_ssl_condition`
String. The inotify conditions on which the CA dir is synced to the passive master.  Default: _/etc/puppetlabs/puppet/ssl/ca/signed IN_CLOSE_WRITE,IN_DELETE_

##### `minute`
String.  Minute of the hour to export database or nc data - used in cron job.  Default: _10_

##### `monthday`
String.  Monthday to export databases or nc data - used in cron job.  Default: _*_

##### `nc_dump_path`
String.  Path to export node classifier exports to.  Default: _/opt/pe_failover/nc_dumps_

##### `pe_bkup_dbs`
Array.  The array of databases that should be backed up.  Default: _['pe-rbac']_

##### `pe_failover_directory`
String.  The base path for all of the failover contents.  Default: _/opt/pe_failover_

##### `pe_users`
Hash.  This hash stores all of the PE users that are required.  See params.pp

##### `restore_db_minute`
String.  Minute of the hour to restore data to passive - used in cron job.  Default: _3_

##### `restore_hour`
String.  Hour of the day to restore to passive - used in cron job.  Default: _*_

##### `restore_monthday`
String.  Monthday to restore to passive - used in cron job.  Default: _*_

##### `restore_nc_minute`
String.  Minute of the hour to restore data to passive - used in cron job.  Default: _0_

##### `rsync_command`
String.  The rsync command to run along with base options.  Default _'rsync -au --delete'_

##### `rsync_ssl_dir`
String.  The path to the CA directory to be transferring to the passive master. Default: _/etc/puppetlabs/puppet/ssl/ca/_

##### `rsync_user`
String. The user used to perform rsync transfers.  This user is managed by pe_failover.  Default _pe-transfer_

##### `rsync_user_home`
String. Home path for the `rsync_user`.  Default: _/home/pe-transfer_

##### `rsync_user_ssh_id`
String.  The path of the ssh_id file to be used for rsync transfers.  Default: _/home/pe-transfer/.ssh/pe_failover_id_rsa_

##### `script_directory`
String.  The path to where script files should be written.  Default: _/opt/pe_failover/scripts_

##### `sync_hour`
String.  Hour of the day to sync to passive - used in cron job.  Default: _*_

##### `sync_minute`
String.  Minute of the hour to sync data to passive - used in cron job.  Default: _20_

##### `sync_monthday`
String.  Monthday to sync to passive - used in cron job.  Default: _*_

