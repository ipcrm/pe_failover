class pe_failover::passive::users {

  # Setup PE Users
  $::pe_failover::passive::pe_users.keys.each |$pe_user| {
    user{$pe_user:
      comment    => $::pe_failover::passive::pe_users[$pe_user]['description'],
      home       => $::pe_failover::passive::pe_users[$pe_user]['home'],
      managehome => false,
      shell      => $::pe_failover::passive::pe_users[$pe_user]['shell'],
    }
  }

}
