import 'package:decimal/decimal.dart';

import './extension/extension.dart';
import '../db/mixin_database.dart';

class SwapAssetMeta {
  SwapAssetMeta(this.swapAsset, List<SwapPair> swapPairs) {
    liquidity = Decimal.zero;
    volume = Decimal.zero;
    trades = 0;
    swapPairs.forEach((swapPair) {
      if (swapAsset.id == swapPair.baseAssetId) {
        liquidity += swapPair.baseAmount.asDecimal;
      } else {
        liquidity += swapPair.quoteAmount.asDecimal;
      }
      volume += swapPair.volume24h.asDecimal;
      trades += swapPair.transactionCount24h ?? 0;
    });
    liquidityWithPrice = liquidity * swapAsset.price.asDecimal;
    liquidityText = liquidityWithPrice.toFiat;
  }
  SwapAsset swapAsset;
  late Decimal liquidity;
  late Decimal liquidityWithPrice;
  late String liquidityText;
  late Decimal volume;
  late int trades;
}

SwapAssetMeta getSwapAssetSwapPairsMeta(
  SwapAsset swapAsset,
  List<SwapPair> swapPairs,
) =>
    SwapAssetMeta(
        swapAsset,
        swapPairs
            .where((swapPair) =>
                swapAsset.id == swapPair.baseAssetId ||
                swapAsset.id == swapPair.quoteAssetId)
            .toList());

SwapAssetMeta getSwapAssetMeta(
  SwapAsset swapAsset,
  List<SwapPair> swapPairs,
) =>
    SwapAssetMeta(
        swapAsset,
        swapPairs
            .where((swapPair) =>
                swapAsset.id == swapPair.baseAssetId ||
                swapAsset.id == swapPair.quoteAssetId)
            .toList());
