class pe_failover::db {
  # Create dumps for each supplied database (pe-rbac ONLY by default)
  $pe_failover::pe_bkup_dbs.each |$db| {
    pe_failover::db_dump { $db:
      minute   => $pe_failover::minute,
      hour     => $pe_failover::hour,
      monthday => $pe_failover::monthday,
    }
  }

  # Update database export perms from pe-transfer to pe-postgres so exports don't fail
  $pe_failover::pe_bkup_dbs.each |$db| {
    file {"${pe_failover::dump_path}/${db}/${db}_latest.psql":
      owner => 'pe-postgres',
      group => 'pe-postgres',
    }
    file {"${pe_failover::dump_path}/${db}/${db}_latest.psql.md5sum":
      owner => 'pe-postgres',
      group => 'pe-postgres',
    }
  }


}
