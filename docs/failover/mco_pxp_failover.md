MCollective and PXP Agent Failover
==================================
Normally PE_FAILOVER assumes the failover of these services will happen when a client retrieves a new
catalog (by default every 30 minutes).  In most scenarios this will be adequate, however in the event
you've configured your clients to use cached catalogs(as is required for Application Orchestration)
you clients will not request an updated catalog from the 'new' master and will never start working.
In this scneario you will need to configure the brokers for both services to have matching hostnames
and passwords and allow the clients to timeout and failover to the 'new' master.  This can easily be
accomplished using hiera to override the values and using a unique DNS name for these services.

### Setup
Here is an example set of hieradata values that use the hostname `puppetha.example.com`:
```yaml
#mcollective
puppet_enterprise::profile::mcollective::peadmin::stomp_password: password
puppet_enterprise::profile::mcollective::agent::activemq_brokers:
  - puppetha.example.com
puppet_enterprise::profile::mcollective::agent::stomp_password: password
puppet_enterprise::profile::amq::broker::stomp_password: password

#orchestration
puppet_enterprise::profile::agent::pcp_broker_host: puppetha.example.com
```

A few things to note.
 - This DNS name must be unique from what your using for your puppet agents.  It CANNOT go behind a
   load balancer.  PXP and MCO clients must be able to do a reverse lookup for the brokers attempting
   to make a connection to them.
 - IF you are using a larger mcollective installation with a hub/spoke topology you should disregard
   this note and use your normal scaling mechanism.

### Behavior
As mentioned previously, this method relies on the clients to 'timeout' and failover to the 'new' master.
Depending on the failure scenario the actual amount of time this takes can vary greatly.  If you've
shutdown the primary master gracefully the time required to failover (after you update DNS and factor in
any caching on your client platforms) should be relatively quick(few minutes).  In the event of a hard failure
of the primary master it will take considerably longer before the connections get reset(~15 minute timeouts).
