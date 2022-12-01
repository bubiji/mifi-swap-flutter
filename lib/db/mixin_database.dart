import 'package:drift/drift.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart'
    show UserRelationship;

import '../mixin_wallet/db/converter/millis_date_converter.dart';
import '../mixin_wallet/db/converter/user_relationship_converter.dart';
import '../mixin_wallet/db/dao/address_dao.dart';
import '../mixin_wallet/db/dao/asset_dao.dart';
import '../mixin_wallet/db/dao/assets_extra_dao.dart';
import '../mixin_wallet/db/dao/fiat_dao.dart';
import '../mixin_wallet/db/dao/snapshot_dao.dart';
import '../mixin_wallet/db/dao/user_dao.dart';
import '../util/logger.dart';
import 'dao/swap_asset_dao.dart';
import 'dao/swap_pair_dao.dart';
import 'database_event_bus.dart';

part 'mixin_database.g.dart';

@DriftDatabase(
  include: {
    'moor/mixin.drift',
    '../mixin_wallet/db/moor/mixin.drift',
    '../mixin_wallet/db/moor/dao/asset.drift',
    '../mixin_wallet/db/moor/dao/snapshot.drift',
    '../mixin_wallet/db/moor/dao/user.drift',
  },
  daos: [
    SwapPairDao,
    SwapAssetDao,
    AddressDao,
    AssetDao,
    SnapshotDao,
    UserDao,
    FiatDao,
    AssetsExtraDao,
  ],
  queries: {},
)
class MixinDatabase extends _$MixinDatabase {
  MixinDatabase(QueryExecutor e) : super(e);

  MixinDatabase.connect(DatabaseConnection c) : super.connect(c);

  @override
  int get schemaVersion => 6;

  final eventBus = DataBaseEventBus();

  @override
  MigrationStrategy get migration => MigrationStrategy(beforeOpen: (_) async {
        if (executor.dialect == SqlDialect.sqlite) {
          await customStatement('PRAGMA journal_mode=WAL');
          await customStatement('PRAGMA foreign_keys=ON');
          await customStatement('PRAGMA synchronous=NORMAL');
        }
      }, onUpgrade: (m, from, to) async {
        d('onUpgrade: $from -> $to');
        await destructiveFallback.onUpgrade(m, from, to);
      });
}
