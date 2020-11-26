import 'package:sqflite_migration/sqflite_migration.dart';

import 'base.dart';

class MiniConfiguration extends DatabaseConfiguration {
  static final List<String> _initializationScripts = [
    '''
      CREATE TABLE minis(
        id INTEGER PRIMARY KEY,
        name TEXT,
        icon TEXT,
        display_order INTEGER,
        itemId INTEGER,
        expiration_date DATE
      )
    '''
  ];

  static final List<String> _migrationScripts = [
    'ALTER TABLE minis RENAME COLUMN expiration_date TO cache_expiration_date',
    'ALTER TABLE minis ADD COLUMN cache_version INTEGER DEFAULT 2'
  ];

  MiniConfiguration() : super(
    name: 'minis.db',
    tableName: 'minis',
    migrationConfig: MigrationConfig(
      initializationScript: _initializationScripts,
      migrationScripts: _migrationScripts
    )
  );
}