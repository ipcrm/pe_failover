#### Table of Contents

1. [Overview](#overview)
    * [Notice](#notice)
    * [Architecture](#architecture)
    * [Deployment Strategies](#deployment-strategies)
    * [Functional State of a Passive or Active Master](#functional-state-of-a-passive-or-active-master)
    * [Determining Master State](#determining-master-state)
    * [Failover](#failover)
    * [Promotion](#promotion)
    * [Failback](#failback)
2. [Setup](#setup)
    * [Prerequisites](#prerequisites)
    * [Installation instructions](#installation-instructions)
      * [Master A](#master-a)
      * [Master B](#master-b)
      * [Classification](#classification)
      * [Validation](#validation)
3. [Reference](#reference)
    * [Users](#users)
    * [Public Classes](#public-classes)
    * [Defined Types](#define)
    * [Scripts](#scripts)
    * [Crons](#crons)
    * [Incron](#incron)
    * [Logging](#logging)
4. [Known Issues](#known-issues)

## Overview

The purpose of this module is to provide failover capabilities for Puppet Enterprise.  By using this module
you will be able to setup a 'Warm' spare master (or master + compile masters) at a secondary location to be used
in the event of a DR like situation.  Please read the following notice _CAREFULLY_ so that you understand what this module
can and cannot do!

#### Notice

This module provides capabilities for a limited HA solution for Puppet Enterprise.

**Availability** is provided for the following services:

- Puppetserver
- CA
- Node Classifier
- PuppetDB
- Orchestrator/PXP
- MCollective

**Data** for the following services is **_not_** protected:

- PuppetDB data, including exported resources, historical reports, and
  historical catalogs
- Orchestrator job history

To be clear - you will have a functional PuppetDB instance on the warm spare master; but there will not
be any historical data populated!

Note that in future versions of Puppet Enterprise (some time long after
2016.1.x), all of these features, including ones mentioned as protected above,
will be included out of the box, and removal of this module will likely be
necessary.

>
> **WARNING - EXPORTED RESOURCES**

> PuppetDB data is NOT preserved from the primary master.  If you are relying on exported resources in your 
> environment this module is _NOT_ for you!  Why?  If you've setup any purge resources that monitor configurations
> that are populated by collecting exported resources your first runs in a failover will _DELETE_ all of
> those configurations and cause major issues for you!

#### Architecture
As stated in the overview the puropse of this module is to provide a warm spare master that can be failed over to at any time.  This module 
takes a simplified approach to HA and does NOT implement any form of database replication.  All data transfers are performed leveraging rsync 
and ssh.  The idea is to provide HA with as much decoupling of each master as possible so that the core PE software doesn't not have to be modified.  

Once configured following the steps in this guide you will wind up with two functional masters, one that you intentionally will not send client traffic
to and this document refers to as the master.  All services will remain up and running on both masters so that you can failover at a moments notice and
service clients from the passive immediately.

The following information is kept in-sync accross masters to provide failover capability:

| Component       | Transfer Method    |Frequency |
| --------------- | ------------------ | --- |
| CA              | incron/rsync  | Near Realtime |
| Node Classifier | rsync  | Hourly        |
| RBAC Database   | rsync  | Hourly        |
| Puppet Code     | r10k/code manaager   | On-demand     |

Again, all services are functional on the passive master, but not all data is syncronized.

#### Deployment Strategies
There is really only two ways to utilize this in your enviornment - DNS or using a loadbalancer.  In either scenario you must set a common DNS alt name to
be used by both masters to service client requests.

DNS being the most straightforward, you would simply point your DNS record at your primary master until which point you'd like to failover.  In the load balancer
scenario you can put both masters in a pool and set the priority to your primary master.  Leveraging health checks your masters can automatically failover if the 
primary becomes unavailable.

#### Functional State of a Passive or Active Master
When a master is `active` it means that it is actively generating export data from the node classifier and rbac database via a scheduled cron job.  In addition, the active
master also will trigger an rsync of the CA directories to the passive any time a certificate is signed or deleted.

A `passive` master has all of its services enabled and is capable of serving client requests, however there are periods when services will be restarted.  There are 2 scheduled
jobs on the passive master; one for restoring node classifier data and one for restoring the RBAC database.  During the NC restore processes no services are stopped as this 
restore is performed via the API.  When the RBAC database restore job runs it will first validate it has a new export present in the database dump directory.  If it finds new
data it will shut down PE services, restore the database from the export, and restart services.

#### Determining Master State
To determine which master is 'active', that is the one that is shipping data and not receiving it, you can simply query the `pe_failover_mode` fact via the following command:

```
# facter -p pe_failover_mode
passive
```

#### Failover
Failover is as simple as pointing your clients at the passive master.  Puppet runs will continue as usual with no impact.  For MCO and PXP, one puppet run must
complete before these services will be restored.  This is due to the fact that the brokers and passwords for these services must be reconfigured.

> **Note: MCollective and PXP Failover**
>
> There is an alternative option for failing over these services, see [here](docs/failover/mco_pxp_failover.md) for details.  This method is required if your leveraging 
> cached catalogs (for example with Application Orchestration) due to the fact that these clients will not retrieve new catalogs on regular timers.
>

In an actual failure scenario where the primary master is offline you do not need to make any changes to the passive master to have it function properly.  If you've 
manually failed over to the passive master and your primary is still online you **MUST** disable the data transfer scripts on the primary (see the reference section for
details).  As long as there is no new export data arriving on the passive master no services will be stopped.

#### Promotion
In order to promote a currently passive master you will need to update a couple of facts.  Edit the `/opt/puppetlabs/facter/facts.d/pe_failover.yaml` file and change the 
mode from passive to active.  Also, you will need to set a new secondary master name.  Run `puppet agent -t` and the master will reconfigure itself.  If your not ready to 
configure a new seconary simply leave this master configured as passive until you are - as mentioned above if there is no new data received this master will _NOT_ stop any services.

#### Failback
Assuming your original master went offline and has come back you have a few options.  If you've made no changes to classification or RBAC you can simply restart the master
and depending on your deployment strategy either update DNS or wait for the loadbalancer to detect the restored master and client traffic will begin to move back to the 
original primary.  If you've made changes you need to save you can _DEMOTE_ this host.  To do this you will update `/opt/puppetlabs/facter/facts.d/pe_failover.yaml` and set 
the mode to passive and update the sshkey as described in the [setup](#setup) section of this guide.  Run `puppet agent -t` and the master will reconfigure itself.  Once you've
allowed adequate time for the export/restore processes to run (just wait 2 hours) you can reverse this process and _DEMOTE_ your current active master and _PROMOTE_ the original.

## Setup
For purposes of this guide we have two masters, one named mastera(primary) and one named masterb(passive).

#### Prerequisites
**On both masters**
- Configure epel repositories (needed for incrond)
  - Example way of doing this
    - `puppet module install stahnma-epel`
    - ` puppet apply -e 'include epel`

#### Installation instructions

##### `Master A`
  - Install Puppet Enterprise
    - **REQUIRED** Make sure that you setup DNS alt names for your certificates!  If you do not do this you cannot use this failover mechanism.

  - Run pe_failover::active
    - Clone this repo into your production code directory
      - cd /etc/puppetlabs/code/environments/production; git clone https://github.com/ipcrm/pe_failover.git
    - puppet apply -e 'include pe_failover; class{pe_failover::active: passive_master => "masterb.example.com"}'

  - Copy the pe-transfer users public key for use when setting up the passive master
    - cat /home/pe-transfer/.ssh/pe_failover_id_rsa.pub and save it off somewhere

##### `Master B`

  - Install Puppet Agent ONLY
    - Do this via an package install directly and not via CURL install from primary master!!!
    - *NOTE*: The agent must match the version installed on the primary master EXACTLY!

  - Run pe_failover::passive
    - Clone this repo into your production code directory
      - cd /etc/puppetlabs/code/environments/production; git clone https://github.com/ipcrm/pe_failover.git
    - puppet apply -e 'include pe_failover; class{pe_failover::passive: auth_key => "_paste your copied key here_"}'

  - Force a sync of the CA directory
    - On _**Master A**_
      - touch /etc/puppetlabs/puppet/ssl/ca/signed/forcesync
    - On _**Master B**_
      - Validate sync is working by using ls -ltr /etc/puppetlabs/puppet/ssl/ca/signed and checking for an empty file called forcesync
      - You can purge the file on _**Master A**_ to force another sync and clean up

  - Run Puppet Enteprise installer
    - Use the _SAME_ dns alt names you used on the primary installation

  - On _**Master A**_
    - Pad the CA serial to make sure newly signed certs don’t collide with the certs signed for the secondary master.  For example, set the current value in /etc/puppetlabs/puppet/ssl/ca/serial to 186A0(100,000)


##### `Classification`
Once you've run through the steps above you will have two functional masters with the same CA cert chain and the ability to
fail back and fourth.  As part of the setup (and more speicifically the pe_failover::active class) there were three groups setup in the 
node classifier.  The are details below.

  - Group 1: pe-failover
    - Parent: All Nodes
    - Rule1: pe_failover_mode match_regex (active|passive)
    - Class1: pe_failover

  - Group 2: pe-failover-active
    - Rule1: pe_failover_mode=active
    - Class1: pe_failover::active

  - Group 3: pe-failover-passive
    - Rule1: pe_failover_mode=passive
    - Class1: pe_failover::passive

These groups are created on mastera and will not be present on masterb until the first sync/restore process runs.  If your impatient you can 
force the issue by running the nc_dump cron job on mastera and the nc_restore job on masterb.

##### `Validation`
At this point your masters are up and running, capable of serving catalogs for the same nodes.  The required data is being sync'd via cron jobs
or incrond.  You can test your setup by pointing a client at either master (using the shared DNS alt name) and running `puppet agent -t` to prove 
its working.  Keep in mind, if your using code manager or r10k on your primary you will still need to set that up on the passive master via the normal process.


## Reference

#### Users
| User       | Class Created    |Purpose |
| -----------| ------------------ | --- |
| pe-transfer  | pe_failover(init.pp)  | Used to recieve rsync transfers on the passive nodes |
#### Public Classes
| Class       | Purpose    |
| -----------| ------------------ |
| [pe_failover](docs/classes/pe_failover.md)  | Base class that is required by passive/active.  Sets up base users, directories, and packages |
| [pe_failover::active](docs/classes/pe_failover_active.md) | Used to classify the active master.  Configures users, scripts, dirs, etc.. |
| [pe_failover::passive](docs/classes/pe_failover_passive.md) | Used to classify the passive master.  Configures users, scripts, dirs, etc.. |
| [pe_failover::params](docs/classes/pe_failover_passive.md) | Default param values |

#### Facts
##### `pe_failover_mode`:
This fact is set in `/opt/puppetlabs/facter/facts.d/pe_failover.yaml` automatically based on the class assigned.  Its used for classification.  Valid values: _active,passive_

##### `pe_failover_key`:
This fact is set in `/opt/puppetlabs/facter/facts.d/pe_failover.yaml` automatically when you include the pe_failover::passive class.  It stores the value of auth_key from the original run of puppet when you configured the master. 

##### `pe_failover_passive_master`:
This fact is set in `/opt/puppetlabs/facter/facts.d/pe_failover.yaml` automatically when you include pe_failover::passive the first time and it uses the supplied param to update the yaml file.  The fact is then used in subsequent runs for various scripts.

#### Define
| Define       | Purpose    |
| -----------| ------------------ |
| [pe_failover::db_dump](docs/defines/db_dump.md)  | Define for setting up postgres database dump |
#### Scripts
| Script       | Purpose    |
| -----------| ------------------ |
| [nc_dump.sh](templates/nc_dump.sh.erb) | Export Node Classifier contents on the primary master and sync to passive |
| [db_dump.sh](templates/db_dump.sh.erb) | Export databases on the primary master and sync to passive |
| [rsync_exclude](templates/rsync_exclude.erb) | Creates a exclude file within the primary masters SSL dir for passive master certs|
| [sync_certs.sh](templates/sync_certs.sh.erb) | Copy the latest CA contents from primary master to passive |
| [update_passive_ca.sh](templates/update_passive_ca.sh.erb) | Update CA on Passive master from latest copy of primary master CA |
| [restore_nc.sh](templates/restore_nc.sh.erb) | Update the contents of the Node Classifier on the passive master |
| [restore_dbs.sh](templates/restore_dbs.sh.erb) | Restore copied databases on the passive master |
#### Crons
| Job       | Master | Type    | Schedule (default) | Purpose |
| --- | --- | --- | --- | --- |
| nc_dump | primary | cron | Every hour @ 10 after | Calls [nc_dump.sh](templates/nc_dump.sh.erb)
| *dbname*_db_dump | primary | cron | Every hour @ 10 after | Calls [db_dump.sh](templates/db_dump.sh.erb) for the given database
| rest_nc_cron | passive | cron | Every hour on the hour | Calls [restore_nc.sh](templates/restore_nc.sh.erb)
| rest_dbs_cron | passive | cron |  Every hour @ 3 after | Calls [restore_dbs.sh](templates/restore_dbs.sh.erb)

#### Incron
| Master | Path (default) | When | Purpose |
| --- | --- | --- | --- |
| primary | /etc/puppetlabs/puppet/ssl/ca/signed | On file create/delete | Calls [sync_certs.sh](templates/sync_certs.sh.erb)
| passive | /opt/pe_failover/cert_dumps/latest/signed | On file create/delete | Calls [update_passive_ca.sh](templates/update_passive_ca.sh.erb)
#### Logging
All logging is done via the logger command to syslog.  All log messages have a common format:

`PE_FAILOVER: <scriptname>.sh ---> [<status>] <message>`

Example:

```
PE_FAILOVER: restore_dbs.sh ---> [SUCCESS] Attempting to start service pe-puppetserver...
```

Valid status messages are `SUCCESS`, `FAILURE`, and `WARNING`.

If your troubleshooting a nice trick is to run `tail -f /var/log/messages|grep PE_FAILOVER &` so that when you run these scripts the log messages are brought to the console realtime. Additionally
for monitoring purposes you can setup alerts based on finding any messages in syslog that match `PE_FAILOVER` and `FAILURE`.


## Known Issues
- Needs tested on other supported platforms for masters
- Exported resources are NOT protected and should not be used with this setup (or at least not used with purge resources)
