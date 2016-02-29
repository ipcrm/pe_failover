### Class: `pe_failover`

Base class that sets up common users, packages, and directories

#### Parameters
##### `pe_failover_directory`

String. This is the base directory that is used to store all scripts and exports.  Default: _/opt/pe_failover_

##### `script_directory`

String. This is the directory that all scripts used by pe_failover are stored in.  Default: _/opt/pe_failover/scripts_

##### `dump_path`

String. The location  where database exports are written to on the active master.  Default: _/opt/pe_failover/dumps_

##### `nc_dump_path`

String. Location of the node classifier exports on the active master.  Default _/opt/pe_failover/nc_dumps_

##### `rsync_user`

String. The user used to perform rsync transfers.  This user is managed by pe_failover.  Default _pe-transfer_

##### `rsync_user_home`

String. Home path for the `rsync_user`.  Default: _/home/pe-transfer_

##### `pe_bkup_dbs`

Array.  The list of PE databases to create dumps for (and restore).  Default: _['pe-rbac']_
