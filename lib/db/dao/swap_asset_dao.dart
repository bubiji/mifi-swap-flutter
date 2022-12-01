import 'package:drift/drift.dart';
import 'package:uniswap_sdk_dart/uniswap_sdk_dart.dart' as mifiswap;

import '../mixin_database.dart';

part 'swap_asset_dao.g.dart';

extension SwapAssetConverter on mifiswap.Asset {
  SwapAssetsCompanion get asSwapAssetsCompanion => SwapAssetsCompanion.insert(
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

@DriftAccessor(tables: [SwapAsset])
class SwapAssetDao extends DatabaseAccessor<MixinDatabase>
    with _$SwapAssetDaoMixin {
  SwapAssetDao(MixinDatabase db) : super(db);

  Future<int> insert(mifiswap.Asset swapAsset) => into(db.swapAssets)
      .insertOnConflictUpdate(swapAsset.asSwapAssetsCompanion);

  Future<void> insertAll(List<SwapAsset> swapAssets) async => batch((batch) {
        batch.insertAllOnConflictUpdate(db.swapAssets, swapAssets);
      });

  Future<int> deleteSwapAsset(SwapAsset swapAsset) =>
      delete(db.swapAssets).delete(swapAsset);

  Future<void> insertAllOnConflictUpdate(
      List<mifiswap.Asset> swapAssets) async {
    await db.delete(db.swapAssets).go();
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.swapAssets,
        swapAssets.map((swapAsset) => swapAsset.asSwapAssetsCompanion).toList(),
      );
    });
  }

  Selectable<SwapAsset> getAll() => select(db.swapAssets);
  Selectable<SwapAsset> get(String id) =>
      select(db.swapAssets)..where((tbl) => tbl.id.equals(id));

  SimpleSelectStatement<SwapAssets, SwapAsset> swapAssets() =>
      select(db.swapAssets);
}
