### Class: `pe_failover::active`
This class is used to configure the passive master.  All required configurations are setup including users, ssh, scripts, cron jobs, incron, pe_failover paths.

The following private classes are included to perform the configuration:

|Class|
|---|
|[pe_failover::passive::ssh](/manifests/passive/ssh.pp)|
|[pe_failover::passive::scripts](/manifests/passive/scripts.pp)|
|[pe_failover::passive::cron](/manifests/passive/cron.pp)|
|[pe_failover::passive::users](/manifests/passive/users.pp)|
|[pe_failover::passive::incron](/manifests/passive/incron.pp)|
|[pe_failover::passive::paths](/manifests/passive/paths.pp)|

#### Parameters
##### `auth_key`
String. Required.  The public key from the pe-transfer use on the active master

#### `rsync_user`
String. The user used to perform rsync transfers.  This user is managed by pe_failover.  Default _pe-transfer_

##### `incron_passive_ssl_condition`
String. The inotify conditions on which the CA dir is synced from the staging directory to the active CA directory.  Default: _/opt/pe_failover/cert_dumps/latest/signed IN_CLOSE_WRITE,IN_DELETE"_

##### `script_directory`
String.  The path to where script files should be written.  Default: _/opt/pe_failover/scripts_

##### `pe_failover_directory`
String.  The base path for all of the failover contents.  Default: _/opt/pe_failover_

##### `pe_bkup_dbs`
Array.  The array of databases that should be backed up.  Default: _['pe-rbac']_

##### `restore_nc_minute`
String.  Minute of the hour to restore data to passive - used in cron job.  Default: _0_

##### `restore_db_minute`
String.  Minute of the hour to restore data to passive - used in cron job.  Default: _3_

##### `restore_hour`
String.  Hour of the day to restore to passive - used in cron job.  Default: _*_

##### `restore_monthday`
String.  Monthday to restore to passive - used in cron job.  Default: _*_

##### `dump_path`
String.  Path to export database backups to.  Default: _/opt/pe_failover/dumps_

##### `nc_dump_path`
String.  Path to export node classifier exports to.  Default: _/opt/pe_failover/nc_dumps_

##### `cert_dump_path`
String.  Path to rsync CA contents to on the passvie.  Default: _/opt/pe_failover/cert_dumps_

