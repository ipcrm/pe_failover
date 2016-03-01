### Class: `pe_failover::active`
This class is used to configure the passive master.  All required configurations are setup including users, ssh, scripts, cron jobs, incron, pe_failover paths.

The following private classes are included to perform the configuration:

|Class|
|---|
|[pe_failover::passive::ssh](/manifests/passive/ssh.pp)|
|[pe_failover::passive::scripts](/manifests/passive/scripts.pp)|
|[pe_failover::passive::cron](/manifests/passive/cron.pp)|
|[pe_failover::passive::incron](/manifests/passive/incron.pp)|
|[pe_failover::passive::files](/manifests/passive/files.pp)|

#### Parameters
##### `auth_key`
String. Required.  The public key from the pe-transfer use on the active master

