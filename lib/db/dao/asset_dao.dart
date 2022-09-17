import 'package:drift/drift.dart';
import 'package:uniswap_sdk_dart/uniswap_sdk_dart.dart' as forswap;

import '../mixin_database.dart';

part 'asset_dao.g.dart';

extension AssetConverter on forswap.Asset {
  AssetsCompanion get asAssetsCompanion => AssetsCompanion.insert(
        id: id,
        logo: logo,
        name: name,
        price: price,
        symbol: symbol == null ? const Value.absent() : Value(symbol),
        extra: extra == null ? const Value.absent() : Value(extra),
        chainId: chainId,
        chainSymbol:
            chain.symbol == null ? const Value.absent() : Value(chain.symbol),
        chainLogo: chain.logo,
        chainName: chain.name,
      );
}

@DriftAccessor(tables: [Asset])
class AssetDao extends DatabaseAccessor<MixinDatabase> with _$AssetDaoMixin {
  AssetDao(MixinDatabase db) : super(db);

  Future<int> insert(forswap.Asset asset) =>
      into(db.assets).insertOnConflictUpdate(asset.asAssetsCompanion);

  Future<void> insertAll(List<Asset> assets) async => batch((batch) {
        batch.insertAllOnConflictUpdate(db.assets, assets);
      });

  Future<int> deleteAsset(Asset asset) => delete(db.assets).delete(asset);

  Future<void> insertAllOnConflictUpdate(List<forswap.Asset> assets) async {
    await db.delete(db.assets).go();
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.assets,
        assets.map((asset) => asset.asAssetsCompanion).toList(),
      );
    });
  }

  Selectable<Asset> getAll() => select(db.assets);
  Selectable<Asset> get(String id) =>
      select(db.assets)..where((tbl) => tbl.id.equals(id));

  SimpleSelectStatement<Assets, Asset> assets() => select(db.assets);
}
