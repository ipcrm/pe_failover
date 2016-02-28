*_WIP DO NOT USE YET_*

_WIP_
- Enable Failback/Failover on the same host (ie don't have to re-create new master)


#### Table of Contents

1. [Overview](#overview)
    * [Notice](#notice)
    * [Architecture](#architecture)
    * [Deployment Strategies](#deployment-strategies)
    * [Failover](#failover)
    * [Failback](#failback)
2. [Setup](#setup)
    * [Prerequisites](#prerequisites)
    * [Installation instructions](#installation-instructions)
3. [Reference](#reference)
    * [Users](#users)
    * [Classes](#classes)
    * [Defined Types](#define)
    * [Scripts](#scripts)
    * [Crons](#crons)
    * [Incron](#incron)

## Overview

The purpose of this module is to provide failover capabilities for Puppet Enterprise.  By using this module 
you will be able to setup a 'Warm' spare master (or master + compile masters) at a secondary location to be used 
in the event of a DR like situation.  Please read the following notice _CAREFULLY_ so that you understand what this module 
can and cannot do!

#### Notice

This module provides capabilities for a limited HA solution for Puppet Enterprise.

Availability is provided for the following services:

- Node Classification
- Certificate signing/revoking

The data for the following services is *not* protected:

- PuppetDB data, including exported resources, historical reports, and
  historical catalogs
- Orchestrator job history

To be clear - you will have a functional PuppetDB instance on the warm spare master; but there will not 
be any data populated!

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
| Puppet Code     | r10k   | On-demand     |

Again, all services are functional on the passive master, but not all data is syncronized. 

#### Deployment Strategies
There is really only two ways to utilize this in your enviornment - DNS or using a Loadbalancer.  In either scenario you must set a common DNS alt name to
be used by both masters to service client requests.

DNS being the most straightforward, you would simply point your DNS record at your primary master until which point you'd like to failover.  In the load balancer
scenario you can put both masters in a pool and set the priority to your primary master.  Leveraging health checks your masters can automatically failover if the 
primary becomes unavailable.

#### Failover
Failover is as simple as pointing your clients at the passive master.  Puppet runs will continue as usual with no impact.  For MCO and PXP, one puppet run must
complete before these services will be restored.  This is due to the fact that the brokers for these services must be reconfigured.
> **Note**
>
> It is possible to make PXP and MCO work immediately if you use a common DNS name for the broker _AND_ match the passwords used on both masters via class overrides
>

In an actual failure scenario where the primary master is offline you do not need to make any changes to the passive master to have it function properly.  If you've 
manually failed over to the passive master and your primary is still online you **MUST** disable the data transfer scripts on the primary (see the reference section for
details).  As long as there is no new data arriving on the passive master no services will be stopped.

#### Failback
~~There is no mechanism for failback built into this module, however if the primary master was only offline temporarily and no classification or RBAC changes have been made 
you can simply re-point your clients back to your primary master.  The only additional thing you would need to do is ensure that the latest codebase has been checked out 
on your primary master prior to returning clients.~~

_WIP_

## Setup
Let's say we have two masters; the primary master we'll call 'mastera' and the secondary 'masterb'.

#### Prerequisites
**On both masters**
- Configure epel repositories (needed for incrond)
  - puppet module install stahnma-epel
  - puppet apply -e 'include epel'

#### Installation instructions

The process in order:

*Master A*
  - Install Puppet Enterprise
    - When you do this - set your DNS alt names so that your clients can use a common name for both masters
  - Run pe_failover::active
    - puppet module install ipcrm-pe_failover
    - puppet apply -e 'class{pe_failover::active: passive_master => "masterb.example.com"}'
  - Copy the pe-transfer users public key used for copying files from primary master to secondary
    - cat /home/pe-transfer/.ssh/pe_failover_id_rsa.pub and save it off somewhere

*Master B*

  - Install Puppet Agent ONLY
    - Do this via an package install directly and not via CURL install from primary master!!!
  - Run pe_failover::passive
    - puppet module install ipcrm-pe_failover
    - puppet apply -e 'class{pe_failover::passive: auth_key => "_paste your copied key here_"
  - This step is run on *MasterA*; This script is used to copy the ssl directory from primary master to the secondary(normally on an automatic basis)
    - /opt/pe_failover/scripts/sync_certs.sh
  - Run Puppet Enteprise installer
    - Use the _SAME_ dns alt names you used on the primary installation

Once you've run through the steps above you will have two functional masters with the same CA cert chain and the ability to
fail back and fourth.

## Reference

#### Users
| User       | Class Created    |Purpose |
| -----------| ------------------ | --- |
| pe-transfer  | pe_failover(init.pp)  | Used to recieve rsync transfers on the passive nodes |
#### Classes
| Class       | Purpose    |
| -----------| ------------------ |
| [pe_failover](docs/classes/pe_failover.md)  | Base class that is required by passive/active.  Sets up base users, directories, and packages |
| [pe_failover::active](docs/classes/pe_failover_active.md) | Used to classify the active master.  Configures users, scripts, dirs, etc.. |
| [pe_failover::passive](docs/classes/pe_failover_passive.md) | Used to classify the passive master.  Configures users, scripts, dirs, etc.. |
| [pe_failover::params](docs/classes/pe_failover_passive.md) | Default param values |

#### Define
| Define       | Purpose    |
| -----------| ------------------ |
| [pe_failover::db_dump](docs/defines/db_dump.md)  | Define for setting up postgres database dump |
#### Scripts
| Script       | Purpose    |
| -----------| ------------------ |
| [nc_dump.sh](docs/scripts/nc_dump.sh.md) | Export Node Classifier contents on the primary master |
| [sync_nc_dumps.sh](docs/scripts/sync_nc_dumps.sh.md) | Copy the Node Classifier export from primary master to passive |
| [db_dump.sh](docs/scripts/db_dump.sh.md) | Export databases on the primary master |
| [sync_dbs.sh](docs/scripts/sync_dbs.sh.md) | Copy the exported databases from primary master to passive |
| [rsync_exclude](docs/scripts/rsync_exclude.md) | Creates a exclude file within the primary masters SSL dir for passive master certs|
| [sync_certs.sh](docs/scripts/sync_certs.sh.md) | Copy the latest CA contents from primary master to passive |
| [update_passive_ca.sh](docs/scripts/update_passive_ca.sh.md) | Update CA on Passive master from latest copy of primary master CA |
| [restore_nc.sh](docs/scripts/restore_nc.sh.md) | Update the contents of the Node Classifier on the passive master |
| [restore_dbs.sh](docs/scripts/restore_dbs.sh.md) | Restore copied databases on the passive master |
#### Crons
| Job       | Master | Type    | Schedule (default) | Purpose |
| --- | --- | --- | --- | --- |
| nc_dump | primary | cron | Every hour @ 10 after | Calls [nc_dump.sh](docs/scripts/nc_dump.sh.md)
| nc_sync | primary | cron | Every hour @ 20 after | Calls [sync_nc_dumps.sh](docs/scripts/sync_nc_dumps.sh.md)
| *dbname*_db_dump | primary | cron | Every hour @ 10 after | Calls [db_dump.sh](docs/scripts/db_dump.sh.md) for the given database
| db_sync | primary  | cron | Every hour @ 20 after | Calls [sync_dbs.sh](docs/scripts/sync_dbs.sh.md)
| rest_nc_cron | passive | cron | Every hour on the hour | Calls [restore_nc.sh](docs/scripts/restore_nc.sh.md)
| rest_dbs_cron | passive | cron |  Every hour @ 3 after | Calls [restore_dbs.sh](docs/scripts/restore_dbs.sh.md)

#### Incron
| Master | Path (default) | When | Purpose |
| --- | --- | --- | --- |
| primary | /etc/puppetlabs/puppet/ssl/ca/signed | On file create/delete | Calls [sync_certs.sh](docs/scripts/sync_certs.sh.md)
| passive | /opt/pe_failover/cert_dumps/latest/signed | On file create/delete | Calls [update_passive_ca.sh](docs/scripts/update_passive_ca.sh.md)

## _Parked for Now_
- Needs tested on other supported platforms for masters
- Common DNS Name for NC Export

