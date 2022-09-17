import 'package:drift/drift.dart';
import 'package:uniswap_sdk_dart/uniswap_sdk_dart.dart' as forswap;

import '../mixin_database.dart';

part 'pair_dao.g.dart';

extension PairConverter on forswap.Pair {
  PairsCompanion get asPairsCompanion => PairsCompanion.insert(
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

@DriftAccessor(tables: [Pair])
class PairDao extends DatabaseAccessor<MixinDatabase> with _$PairDaoMixin {
  PairDao(MixinDatabase db) : super(db);

  Future<int> insert(Pair pair) => into(db.pairs).insertOnConflictUpdate(pair);

  Future<void> insertAll(List<Pair> pairs) async => batch((batch) {
        batch.insertAllOnConflictUpdate(db.pairs, pairs);
      });

  Future<int> deletePair(Pair pair) => delete(db.pairs).delete(pair);

  Future<void> insertAllOnConflictUpdate(List<forswap.Pair> pairs) async {
    await db.delete(db.pairs).go();
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.pairs,
        pairs.map((pair) => pair.asPairsCompanion).toList(),
      );
    });
  }

  Selectable<Pair> getAll() => select(db.pairs);

  SimpleSelectStatement<Pairs, Pair> pairs() => select(db.pairs);
}
