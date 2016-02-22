#!/bin/bash

usage (){
  echo ""
  echo "Usage: $0 '<ssh key>'"
  echo ""
  echo "The purpose of this script is to install the pre-reqs to make this server be a capable failover Puppet Enterprise master."
  echo "This script will create required users, and setup SSH keys as required for rsync"
  echo "The script takes one argument, a public sshkey(quoted) from the pe-puppet user on the primary master."
  echo ""
  echo ""
}

if [ -z $1 ]; then
  echo ""
  echo "Error! Must supply ssh key (quoted) as argument! Exiting..."
  usage
  exit 1
fi

if [ !`echo "${1}"|egrep "^(\s+)?ssh"` ]; then
  echo ""
  echo "Error! Unknown Argument passed! Exiting..."
  usage
  exit 2
fi

export FACTER_pe_failover_auth_key="${1}"
/opt/puppetlabs/puppet/bin/puppet apply -e 'include pe_failover::passive'

if [ $? -ne -0 ]; then
  echo ""
  echo "Error! Passive setup did NOT complete successfully!"
  exit 4
fi


