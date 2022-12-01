import 'package:drift/drift.dart';
import 'package:uniswap_sdk_dart/uniswap_sdk_dart.dart' as mifiswap;

import '../mixin_database.dart';

part 'swap_pair_dao.g.dart';

extension SwapPairConverter on mifiswap.Pair {
  SwapPairsCompanion get asSwapPairsCompanion => SwapPairsCompanion.insert(
        baseAmount: baseAmount,
        baseAssetId: baseAssetId,
        baseValue: baseValue,
        baseVolume24h: baseVolume24h,
        fee24h: fee24h,
        feePercent: feePercent,
        liquidity: liquidity,
        liquidityAssetId: liquidityAssetId,
        maxLiquidity: maxLiquidity,
        quoteAmount: quoteAmount,
        quoteAssetId: quoteAssetId,
        quoteValue: quoteValue,
        quoteVolume24h: quoteVolume24h,
        routeId: routeId == null ? const Value.absent() : Value(routeId),
        swapMethod:
            swapMethod == null ? const Value.absent() : Value(swapMethod),
        transactionCount24h: transactionCount24h == null
            ? const Value.absent()
            : Value(transactionCount24h),
        version: version == null ? const Value.absent() : Value(version),
        volume24h: volume24h,
      );
}

@DriftAccessor(tables: [SwapPair])
class SwapPairDao extends DatabaseAccessor<MixinDatabase>
    with _$SwapPairDaoMixin {
  SwapPairDao(MixinDatabase db) : super(db);

  Future<int> insert(SwapPair swapPair) =>
      into(db.swapPairs).insertOnConflictUpdate(swapPair);

  Future<void> insertAll(List<SwapPair> swapPairs) async => batch((batch) {
        batch.insertAllOnConflictUpdate(db.swapPairs, swapPairs);
      });

  Future<int> deleteSwapPair(SwapPair swapPair) =>
      delete(db.swapPairs).delete(swapPair);

  Future<void> insertAllOnConflictUpdate(List<mifiswap.Pair> swapPairs) async {
    await db.delete(db.swapPairs).go();
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.swapPairs,
        swapPairs.map((swapPair) => swapPair.asSwapPairsCompanion).toList(),
      );
    });
  }

  Selectable<SwapPair> getAll() => select(db.swapPairs);

  SimpleSelectStatement<SwapPairs, SwapPair> swapPairs() =>
      select(db.swapPairs);
}
