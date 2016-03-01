### Define: `db_dump`
This define is used to setup database exports for each database to be backed up.  It first creates a script for running the export which will utilize the pe-postgres user.  After the script is created it will create a cron job to actually run the export.

#### Parameters
##### `db_name` **REQUIRED**
The name of the database to be exported.

##### `pg_dump_command`
The command to use when running the export.  Default: _/opt/puppetlabs/server/bin/pq_dump_

##### `dump_path`
The path to write the export to. Note the script will write the backup to a subdirectory named after the databse.  Default: _/opt/pe_failover/_

##### `script_directory`
Where to create the script for backup.  Default: _/opt/pe_failover/scripts_

##### `minute`
Minute for the cron job. Default: _10_

##### `hour`
Hour for the cron job.  Default: _*_

##### `monthday`
Monthday for the cron job.  Default: _*_

##### `timestamp_command`
Command used to generate a timestamp used in naming files.  Default: _'\`/bin/date +"%Y-%m-%d-%H%M"\`'_

##### `md5sum_command`
Command to use to generate the md5sum files from the exports.  Default: _/bin/md5sum_
