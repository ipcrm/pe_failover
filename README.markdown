## Overview

This module provides capabilities for a limited HA solution for Puppet Enterprise.

Some level of availability is provided for the following services:

- Node Classification
- Certificate signing/revoking

The following are *not* protected:

- PuppetDB data, including exported resources, historical reports, and
  historical catalogs
- Orchestrator jobs

Note that in future versions of Puppet Enterprise (some time long after
2016.1.x), all of these features, including ones mentioned as protected above,
will be included out of the box, and removal of this module will likely be
necessary.

## Installation instructions
Let's say we have two masters; the primary master we'll call 'mastera' and the secondary 'masterb'


### On MasterA

- as root
  - puppet module install stahnma-epel
  - puppet apply -e 'include epel'
  - puppet module install ipcrm-pe_failover
  - puppet apply -e 'include pe_failover; class{pe_failover::active: passive_master => "masterb"}'
  - ssh-keygen -t rsa -f /root/.ssh/pe_failover_id_rsa
  - cat /root/.ssh/pe_failover_id_rsa.pub (copy to your clipboard)
  - ssh masterb (accept key, control-c)

### On MasterB
- as root
  - puppet module install ipcrm-pe_failover-
  - puppet apply -e 'include pe_failover; class{pe_failover::passive: auth_key => "<primary master rsync user public key"}'



## Failover and failback instructions

_WIP_

## ToDo Docs

Permanent Classification
