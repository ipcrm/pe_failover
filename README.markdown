*_WIP DO NOT USE YET_*

## Overview

The purpose of this module is to provide failover capabilities for Puppet Enterprise.  By using this module 
you will be able to setup a 'Warm' spare master (or master + compile masters) at a secondary location to be used 
in the event of a DR like situation.  Please read the following notice _CAREFULLY_ so that you understand what this module 
can and cannot do!

### NOTICE

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

``` 
WARNING - EXPORTED RESOURCES

PuppetDB data is NOT preserved from the primary master.  If you are relying on exported resources in your 
environment this module is _NOT_ for you!  Why?  If you've setup any purge resources that monitor configurations
that are populated by collecting exported resources your first runs in a failover will _DELETE_ all of
those configurations and cause major issues for you!

```


## Installation instructions
Let's say we have two masters; the primary master we'll call 'mastera' and the secondary 'masterb'.

The process in order:

*Master A*
  - Install Puppet Enterprise
    - When you do this - set your DNS alt names so that your clients can use a common name for both masters
  - Configure epel repositories (needed for incrond)
    - puppet module install stahnma-epel
    - puppet apply -e 'include epel'
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
    - puppet apply -e 'class{pe_failover::passive: auth_key => "<paste your copied key here>"
  - This step is run on *MasterA*; Copy the ssl directory from primary master
    - /opt/pe_failover/scripts/sync_certs.sh
  - Run Puppet Enteprise installer
    - Use the _SAME_ dns alt names you used on the primary installation

Once you've run through the steps above you will have two functional masters with the same CA cert chain and the ability to
fail back and fourth.

## Failover and failback instructions
_WIP_

## What does it actually do
_WIP_

## Refrence
_WIP_

### Users
### Crons/Scheduled Jobs
### Classes
### Define
### Scripts

## _Parked for Now_
- Needs tested on other supported platforms for masters
- Common DNS Name for NC Export


