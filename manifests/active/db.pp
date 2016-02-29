class pe_failover::active::db {
  # Create dumps for each supplied database (pe-rbac ONLY by default)
  $pe_failover::active::pe_bkup_dbs.each |$db| {
    pe_failover::db_dump { $db:
      minute   => $pe_failover::active::minute,
      hour     => $pe_failover::active::hour,
      monthday => $pe_failover::active::monthday,
    }
  }

  # Update database export perms from pe-transfer to pe-postgres so exports don't fail
  $pe_failover::active::pe_bkup_dbs.each |$db| {
    file {"${pe_failover::active::dump_path}/${db}/${db}_latest.psql":
      owner => 'pe-postgres',
      group => 'pe-postgres',
    }
    file {"${pe_failover::active::dump_path}/${db}/${db}_latest.psql.md5sum":
      owner => 'pe-postgres',
      group => 'pe-postgres',
    }
  }


}
