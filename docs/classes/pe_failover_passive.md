### Class: `pe_failover::passive`
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
##### `auth_key` **REQUIRED ON FIRST RUN**
String. The public key from the pe-transfer use on the active master.  The first time you run this class you must supply a value for this class.  During the run it gets stored into pe_failover.yaml and is loaded as a fact which will be used on subsequent runs.


