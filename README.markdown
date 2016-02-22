## Overview

WIP WIP WIP

## Steps
Let's say we have two masters; the primary master we'll call 'mastera' and the secondary 'masterb'


## On MasterA

- as root
-- puppet module install stahnma-epel
-- puppet apply -e 'include epel'
-- puppet module install ipcrm-pe_failover
-- puppet apply -e 'include pe_failover; class{pe_failover::active: passive_master => "masterb"}'
-- ssh-keygen -t rsa -f /root/.ssh/pe_failover_id_rsa
-- cat /root/.ssh/pe_failover_id_rsa.pub (copy to your clipboard)
-- ssh masterb (accept key, control-c)

## On MasterB
- as root
-- puppet module install ipcrm-pe_failover
-- cd /etc/puppetlabs/code/environments/production/modules/pe_failover/scripts
-- ./setup_passive.sh <paste public key here>



## ToDo Docs

Permanent Classification
