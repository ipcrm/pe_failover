class pe_failover::passive::ssh {

  # Setup auth keys
  if $::pe_failover::passive::auth_key != '' {
    ssh_authorized_key{"${::pe_failover::passive::rsync_user}@primary":
      user => $::pe_failover::passive::rsync_user,
      type => 'ssh-rsa',
      key  => $::pe_failover::passive::auth_key,
    }
  }else{
    fail('There is no value for auth_key parameter!')
  }

}
