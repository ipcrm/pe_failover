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
|[pe_failover::active::classification](/manifests/active/classification.pp)|

#### Parameters
##### `passive_master` **REQUIRED**
String.  The full fqdn of the passive master.

##### `exclude_certs`
Array. This parameter gives you the ability to add excluded certificates from the CA update process.  Where this is useful is if your passive master is not just 1 server, but rather a group of compile master plus a monolithic master.  Default: _[]_
