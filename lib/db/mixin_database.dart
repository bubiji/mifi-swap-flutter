import 'package:drift/drift.dart';

import 'dao/asset_dao.dart';
import 'dao/pair_dao.dart';
import 'database_event_bus.dart';

part 'mixin_database.g.dart';

@DriftDatabase(
  include: {
    'moor/mixin.drift',
  },
  daos: [
    PairDao,
    AssetDao,
  ],
  queries: {},
)
class MixinDatabase extends _$MixinDatabase {
  MixinDatabase(QueryExecutor e) : super(e);

  MixinDatabase.connect(DatabaseConnection c) : super.connect(c);

  @override
  int get schemaVersion => 5;

  final eventBus = DataBaseEventBus();

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (_) async {
          if (executor.dialect == SqlDialect.sqlite) {
            await customStatement('PRAGMA journal_mode=WAL');
            await customStatement('PRAGMA foreign_keys=ON');
            await customStatement('PRAGMA synchronous=NORMAL');
          }
        },
        onUpgrade: (m, from, to) async {
          // delete all tables and restart
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
            await m.createTable(table);
          }
        },
      );
}
