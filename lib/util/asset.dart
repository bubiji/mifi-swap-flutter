import 'package:decimal/decimal.dart';

import './extension/extension.dart';
import '../db/mixin_database.dart';

class AssetMeta {
  AssetMeta(this.asset, List<Pair> pairs) {
    liquidity = Decimal.zero;
    volume = Decimal.zero;
    trades = 0;
    pairs.forEach((pair) {
      if (asset.id == pair.baseAssetId) {
        liquidity += pair.baseAmount.asDecimal;
      } else {
        liquidity += pair.quoteAmount.asDecimal;
      }
      volume += pair.volume24h.asDecimal;
      trades += pair.transactionCount24h ?? 0;
    });
    liquidityWithPrice = liquidity * asset.price.asDecimal;
    liquidityText = liquidityWithPrice.toFiat;
  }
  Asset asset;
  late Decimal liquidity;
  late Decimal liquidityWithPrice;
  late String liquidityText;
  late Decimal volume;
  late int trades;
}

AssetMeta getAssetMeta(
  Asset asset,
  List<Pair> pairs,
) =>
    AssetMeta(
        asset,
        pairs
            .where((pair) =>
                asset.id == pair.baseAssetId || asset.id == pair.quoteAssetId)
            .toList());
