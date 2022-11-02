import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:hashids2/hashids2.dart';
import 'package:memoized/memoized.dart';

import './extension/extension.dart';
import '../db/mixin_database.dart';

class PairOverview {
  PairOverview() {
    volume24h = Decimal.zero;
    totalUSDValue = Decimal.zero;
    fee24h = Decimal.zero;
    transactions = 0;
    turnOver = Decimal.zero;
  }
  late Decimal volume24h;
  late Decimal totalUSDValue;
  late Decimal fee24h;
  late int transactions;
  late Decimal turnOver;

  void plus(Pair pair) {
    volume24h += pair.volume24h.asDecimal;
    totalUSDValue += pair.baseValue.asDecimal + pair.quoteValue.asDecimal;
    fee24h += pair.fee24h.asDecimal;
    transactions += pair.transactionCount24h ?? 0;
    turnOver =
        (volume24h / totalUSDValue).toDecimal(scaleOnInfinitePrecision: 8);
  }
}

Asset getAssetById(List<Asset> assets, String id) =>
    assets.firstWhere((asset) => asset.id == id);

class PairMeta {
  PairMeta(this.pair, List<Asset> assets) {
    const priorities = ['XIN', 'ETH', 'BTC', 'DAI', 'USDC', 'pUSD', 'USDT'];
    baseAsset = getAssetById(assets, pair.baseAssetId);
    quoteAsset = getAssetById(assets, pair.quoteAssetId);

    final baseIndex = priorities.indexOf(baseAsset.symbol ?? '');
    final quoteIndex = priorities.indexOf(quoteAsset.symbol ?? '');
    reverse = quoteIndex < baseIndex;
    if (reverse) {
      pair = getReversePair(pair);
      final tmpAsset = baseAsset;
      baseAsset = quoteAsset;
      quoteAsset = tmpAsset;
    }

    price = getPairPrice(pair, reverse: false);
    reversePrice = getPairPrice(pair, reverse: true);

    final baseSymbol = baseAsset.symbol;
    final quoteSymbol = quoteAsset.symbol;

    symbol = '$baseSymbol / $quoteSymbol';

    volume = pair.quoteValue.asDecimal + pair.baseValue.asDecimal;
    turnOver = Decimal.zero;
    if (volume > Decimal.zero) {
      turnOver = (pair.volume24h.asDecimal / volume)
          .toDecimal(scaleOnInfinitePrecision: 8);
    }

    // price format

    var priceFormat = price.priceFormat;
    final priceLength = priceFormat.length;
    if (priceLength > 8) {
      priceFormat = priceFormat.substring(0, 8);
    }
    var reversePriceFormat = reversePrice.priceFormat;
    final reversePriceLength = reversePriceFormat.length;
    if (reversePriceLength > 8) {
      reversePriceFormat = reversePriceFormat.substring(0, 8);
    }

    priceText = '1 $baseSymbol ≈ $priceFormat $quoteSymbol';
    reversePriceText = '1 $quoteSymbol ≈ $reversePriceFormat $baseSymbol';
  }
  Pair pair;
  late bool reverse;
  late Decimal price;
  late Decimal reversePrice;
  late String symbol;
  late Decimal volume;
  late Decimal turnOver;
  late String priceText;
  late String reversePriceText;
  late Asset baseAsset;
  late Asset quoteAsset;
  // late Asset liquidityAsset;
}

List<PairMeta> makePairMeta(List<Pair> pairs, List<Asset> assets) {
  if (assets.isNotEmpty) {
    return pairs.map((pair) => PairMeta(pair, assets)).toList();
  } else {
    return [];
  }
}

Pair getReversePair(Pair pair) => Pair(
      quoteAmount: pair.baseAmount,
      quoteAssetId: pair.baseAssetId,
      quoteValue: pair.baseValue,
      quoteVolume24h: pair.baseVolume24h,
      // quoteSymbol: pair.baseSymbol,
      // quoteLogo: pair.baseLogo,
      // quoteName: pair.baseName,
      baseAmount: pair.quoteAmount,
      baseAssetId: pair.quoteAssetId,
      baseValue: pair.quoteValue,
      baseVolume24h: pair.quoteVolume24h,
      // baseSymbol: pair.quoteSymbol,
      // baseLogo: pair.quoteLogo,
      // baseName: pair.quoteName,
      fee24h: pair.fee24h,
      feePercent: pair.feePercent,
      liquidity: pair.liquidity,
      liquidityAssetId: pair.liquidityAssetId,
      maxLiquidity: pair.maxLiquidity,
      routeId: pair.routeId,
      transactionCount24h: pair.transactionCount24h,
      version: pair.version,
      volume24h: pair.volume24h,
      // liquiditySymbol: pair.liquiditySymbol,
      // liquidityLogo: pair.liquidityLogo,
      // liquidityName: pair.liquidityName,
    );

Decimal getUniPairPrice(Pair pair, {bool reverse = false}) {
  final baseAmount = pair.baseAmount.asDecimal;
  final quoteAmount = pair.quoteAmount.asDecimal;
  if (reverse) {
    if (quoteAmount > Decimal.zero) {
      return (baseAmount / quoteAmount).toDecimal(scaleOnInfinitePrecision: 8);
    }
  }
  if (baseAmount > Decimal.zero) {
    return (quoteAmount / baseAmount).toDecimal(scaleOnInfinitePrecision: 8);
  }
  return Decimal.zero;
}

Decimal getCurvePairPrice(Pair pair, {bool reverse = false}) {
  final curve = Curve(A.asDecimal);
  final fillPercent = Decimal.one - pair.feePercent.asDecimal;
  final baseAmount = pair.baseAmount.asDecimal;
  final quoteAmount = pair.quoteAmount.asDecimal;

  if (reverse) {
    return curve.swapReverse(
      x: baseAmount,
      y: quoteAmount,
      dy: fillPercent,
    );
  }

  return curve.swap(x: baseAmount, y: quoteAmount, dx: fillPercent);
}

Decimal getPairPrice(Pair pair, {bool reverse = false}) =>
    pair.swapMethod == 'curve'
        ? getCurvePairPrice(pair, reverse: reverse)
        : getUniPairPrice(pair, reverse: reverse);

const nCoins = 2;
const one = 1;
const two = 2;

const A = 200;

class Curve {
  Curve(this.a);
  Decimal a;

  Decimal getD(List<Decimal> xp) {
    var sum = Decimal.zero;
    xp.forEach((n) {
      sum += n;
    });
    if (sum <= Decimal.zero) {
      return Decimal.zero;
    }

    var dp = Decimal.zero;
    var d = sum;
    final ann = a * nCoins.asDecimal;

    for (var i = 0; i < 255; i++) {
      var dp0 = d;
      xp.forEach((x0) {
        dp0 = ((dp0 * d) / (x0 * nCoins.asDecimal))
            .toDecimal(scaleOnInfinitePrecision: 8);
      });

      dp = d;
      final d1 = (ann - one.asDecimal) * d;
      final d2 = (nCoins.asDecimal + one.asDecimal) * dp0;
      d = (((ann * sum + dp0 * nCoins.asDecimal) * d) / (d1 + d2))
          .toDecimal(scaleOnInfinitePrecision: 8);

      final diff = d - dp;
      if (diff == Decimal.zero) {
        break;
      }
    }
    return d;
  }

  Decimal getY(Decimal d, Decimal x) {
    final ann = a * nCoins.asDecimal;
    var c = ((d * d) / (x * nCoins.asDecimal))
        .toDecimal(scaleOnInfinitePrecision: 8);
    c = ((c * d) / (ann * nCoins.asDecimal))
        .toDecimal(scaleOnInfinitePrecision: 8);

    final b = x + (d / ann).toDecimal(scaleOnInfinitePrecision: 8);

    var yp = Decimal.zero;
    var y = d;

    for (var i = 0; i < 255; i++) {
      yp = y;
      y = ((y * y + c) / (y + y + b - d))
          .toDecimal(scaleOnInfinitePrecision: 8);

      final diff = y - yp;
      if (diff == Decimal.zero) {
        break;
      }
    }

    return y;
  }

  Decimal getX(Decimal d, Decimal y) {
    final ann = a * nCoins.asDecimal;
    final k = ((d * d * d) / (ann * nCoins.asDecimal * nCoins.asDecimal))
        .toDecimal(scaleOnInfinitePrecision: 8);
    final j = (d / ann).toDecimal(scaleOnInfinitePrecision: 8) - d + y + y;
    final n = ((y - j) / two.asDecimal).toDecimal(scaleOnInfinitePrecision: 8);
    final x = sqrt(((k / y).toDecimal(scaleOnInfinitePrecision: 8) + n * n)
                .toDouble())
            .asDecimal +
        n;
    return x;
  }

  // swap A for B
  // x, y is liquidity of A, B
  // dx is supply amount of A
  Decimal swap({
    required Decimal x,
    required Decimal y,
    required Decimal dx,
    Decimal? d,
  }) {
    final v10e8 = 10e8.asDecimal;
    final x0 = x * v10e8;
    final y0 = y * v10e8;
    final dx0 = dx * v10e8;
    final d1 = d ?? getD([x0, y0]);
    final x1 = x0 + dx0;
    final y1 = getY(d1, x1);
    final dy = (y0 - y1) / v10e8;
    return dy.toDecimal(scaleOnInfinitePrecision: 8);
  }

  // // swap A for B
  // // x, y is liquidity of A, B
  // // dy is wanted amount of B
  Decimal swapReverse({
    required Decimal x,
    required Decimal y,
    required Decimal dy,
    Decimal? d,
  }) {
    final v10e8 = 10e8.asDecimal;
    final x0 = x * v10e8;
    final y0 = y * v10e8;
    final dy0 = dy * v10e8;
    final d1 = d ?? getD([x0, y0]);
    final y1 = y0 - dy0;
    final x1 = getX(d1, y1);
    final dx = (x1 - x0) / v10e8;
    return dx.toDecimal(scaleOnInfinitePrecision: 8);
  }

  Decimal getPriceImpact(Decimal dx, Decimal dy) {
    if (dx == Decimal.zero) {
      return Decimal.zero;
    }
    final v = Decimal.one - (dy / dx).toDecimal(scaleOnInfinitePrecision: 8);
    if (v > Decimal.zero) {
      return v;
    }
    return Decimal.zero;
  }
}

class Uniswap {
  const Uniswap();
  // swap A for B
  // x, y is liquidity of A, B
  // dx is supply amount of A
  // k is liquidity of pair
  Decimal swap({
    required Decimal x,
    required Decimal y,
    required Decimal dx,
    Decimal? k,
  }) {
    final k0 = k ?? x * y;
    final x0 = x + dx;
    final y0 = (k0 / x0).toDecimal(scaleOnInfinitePrecision: 8);
    final dy = y - y0;
    return dy;
  }

//
//   // swap A for B
//   // x, y is liquidity of A, B
//   // dx is supply amount of A
//   // dy is wanted amount of B
  Decimal swapReverse({
    required Decimal x,
    required Decimal y,
    required Decimal dy,
    Decimal? k,
  }) {
    final k0 = k ?? x * y;
    final y0 = y - dy;
    final x0 = (k0 / y0).toDecimal(scaleOnInfinitePrecision: 8);
    final dx = x0 - x;
    return dx;
  }

  Decimal getPriceImpact(Decimal x, Decimal y, Decimal dx, Decimal dy) {
    if (x == Decimal.zero || y == Decimal.zero) {
      return Decimal.zero;
    }
    final yy = y - dy;
    final xx = x + dx;
    final zz = y / x;
    if (xx == Decimal.zero) {
      return Decimal.zero;
    }
    final v =
        Decimal.one - ((yy / xx) / zz).toDecimal(scaleOnInfinitePrecision: 8);
    if (v > Decimal.zero) {
      return v;
    }
    return Decimal.zero;
  }
}

// import BigNumber from "bignumber.js";
// import Hashids from "hashids";
// import { Uniswap } from "@/utils/swap/uniswap";
// import { Curve, A } from "@/utils/swap/curve";
//
const hashSalt = 'uniswap routes';
// const uniswap = new Uniswap();
// const curve = new Curve(A);
// const precision = 8;

class SwapParams {
  SwapParams({
    required this.inputAsset,
    required this.outputAsset,
    this.inputAmount,
    this.outputAmount,
  });
  String inputAsset;
  String outputAsset;
  String? inputAmount;
  String? outputAmount;
}

class RouteCtx with EquatableMixin {
  const RouteCtx({
    required this.routeAssets,
    required this.routeIds,
    required this.amount,
    required this.funds,
    required this.priceImpact,
  });
  final List<String> routeAssets;
  final List<int> routeIds;
  final Decimal amount;
  final Decimal funds;
  final Decimal priceImpact;

  @override
  List<Object?> get props => [
        routeAssets,
        routeIds,
        amount,
        funds,
        priceImpact,
      ];
}

class PreOrder with EquatableMixin {
  const PreOrder({
    required this.ctx,
    required this.routes,
    required this.fillAssetId,
    required this.payAssetId,
    required this.state,
    required this.amount,
    required this.funds,
  });
  final RouteCtx ctx;
  final String routes;
  final String fillAssetId;
  final String payAssetId;
  final String state;
  final String amount;
  final String funds;

  @override
  List<Object?> get props => [
        ctx,
        routes,
        fillAssetId,
        payAssetId,
        state,
        amount,
        funds,
      ];
}

class RouteQueueItem {
  RouteQueueItem({
    required this.key,
    required this.ctx,
  });
  RouteCtx ctx;
  String key;
}

class RoutePair {
  RoutePair({
    required this.pair,
    required this.K,
    required this.baseAmount,
    required this.quoteAmount,
    required this.fillPercent,
    required this.D,
  });
  Pair pair;
  Decimal K;
  Decimal baseAmount;
  Decimal quoteAmount;
  Decimal fillPercent;
  Decimal D;
}

class SwapResult {
  SwapResult({
    required this.funds,
    required this.amount,
    required this.priceImpact,
  });
  Decimal funds;
  Decimal amount;
  Decimal priceImpact;
}

class PairRoutes {
  PairRoutes() {
    curve = Curve(A.asDecimal);
    uniswap = const Uniswap();
    hashids = HashIds(salt: hashSalt);
    cacheGetPair = Memoized2(getPair);
  }
  List<RoutePair> pairs = [];
  Map<String, List<String>> routes = {};
  Map<String, List<List<String>>> cacheRouteAssetIds = {};
  late Uniswap uniswap;
  late Curve curve;
  late HashIds hashids;
  late Memoized2<RoutePair?, String, String> cacheGetPair;

  void makeRoutes(List<Pair> pairs) {
    this.pairs = pairs.map((p) {
      final baseAmount = p.baseAmount.asDecimal;
      final quoteAmount = p.quoteAmount.asDecimal;
      final fillPercent = Decimal.one - p.feePercent.asDecimal;

      var d = Decimal.zero;
      if (p.swapMethod == 'curve') {
        d = curve
            .getD([baseAmount * 10e8.asDecimal, quoteAmount * 10e8.asDecimal]);
      }

      return RoutePair(
        pair: p,
        baseAmount: baseAmount,
        quoteAmount: quoteAmount,
        fillPercent: fillPercent,
        K: baseAmount * quoteAmount,
        D: d,
      );
    }).toList();

    this.pairs.forEach((pair) {
      setAssetRoute(pair.pair.baseAssetId, pair);
      setAssetRoute(pair.pair.quoteAssetId, pair);
    });
  }

  void setAssetRoute(String asset, RoutePair pair) {
    final routes = this.routes[asset] ?? [];
    final opposit = getOppositeAsset(pair, asset);

    if (!routes.contains(opposit)) {
      routes.add(opposit);
      this.routes[asset] = routes;
    }
  }

  RoutePair? getPair(String base, String quote) {
    final idx = pairs.indexWhere((p) {
      final pair1 = p.pair.baseAssetId == base && p.pair.quoteAssetId == quote;
      final pair2 = p.pair.baseAssetId == quote && p.pair.quoteAssetId == base;
      return pair1 || pair2;
    });

    if (idx == -1) {
      return null;
    }
    return pairs[idx];
  }

  RoutePair? getPairByRouteId(int id) {
    final idx = pairs.indexWhere((p) => p.pair.routeId == id);
    if (idx == -1) {
      return null;
    }
    return pairs[idx];
  }

  String getOppositeAsset(RoutePair pair, String input) =>
      input == pair.pair.baseAssetId
          ? pair.pair.quoteAssetId
          : pair.pair.baseAssetId;

  void getPreOrder(
      SwapParams params, void Function(String?, PreOrder?) callback) {
    RouteCtx? bestRoute;
    final funds = params.inputAmount;
    var amount = params.outputAmount;

    if (params.inputAmount != null) {
      if ((params.inputAmount?.asDecimal ?? Decimal.zero) <= Decimal.zero) {
        callback('swap.error.input-amount-invalid', null);
        return;
      }
      bestRoute = getRoutes(params.inputAsset, params.outputAsset,
          params.inputAmount?.asDecimal ?? Decimal.zero);
      amount = (bestRoute?.amount ?? Decimal.zero).round(scale: 8).toString();
    } else if (params.outputAmount != null) {
      if ((params.outputAmount?.asDecimal ?? Decimal.zero) <= Decimal.zero) {
        callback('swap.error.output-amount-invalid', null);
        return;
      }
      // bestRoute = getRoutesReverse(params.inputAsset, params.outputAsset,
      //     params.outputAmount?.asDecimal ?? Decimal.zero);
      // funds = (bestRoute?.funds ?? Decimal.zero).toString();
    } else {
      callback('swap.error.need-input-or-output', null);
      return;
    }
    if (bestRoute == null) {
      callback('swap.error.no-pair-route-found', null);
      return;
    }

    if (amount == null || funds == null) {
      callback('swap.error.swap-amount-not-support', null);
      return;
    }

    if (amount.asDecimal <= Decimal.zero || funds.asDecimal <= Decimal.zero) {
      callback('swap.error.swap-amount-not-support', null);
      return;
    }

    callback(
        null,
        PreOrder(
          ctx: bestRoute,
          amount: amount,
          funds: funds,
          fillAssetId: params.outputAsset,
          payAssetId: params.inputAsset,
          routes: hashids.encode(bestRoute.routeIds),
          state: 'Done',
        ));
    return;
  }

  RouteCtx? getRoutes(
      String inputAsset, String outputAsset, Decimal inputAmount) {
    final queue = getRouteAssetIds(inputAsset, outputAsset);
    RouteCtx? bestRoute;

    final cacheSwap = Memoized3(swap);
    final caches = <String, RouteCtx>{};

    while (queue.isNotEmpty) {
      final assetIdList = queue.removeLast();

      var stepInputAmount = inputAmount;
      var stepInputAsset = inputAsset;

      var routeAssets = [inputAsset];
      var routeIds = <int>[];
      var amount = Decimal.zero;
      var funds = Decimal.zero;
      var priceImpact = Decimal.zero;
      var assetId = '';
      var startIdx = 0;

      final queue2 = [inputAsset, ...assetIdList];

      while (queue2.isNotEmpty) {
        queue2.removeLast();
        final cacheCtx = caches[queue2.toString()];
        if (cacheCtx != null) {
          startIdx = queue2.length - 1;
          break;
        }
      }

      for (var i = startIdx; i < assetIdList.length; i++) {
        assetId = assetIdList[i];

        final cacheCtx = caches[[...routeAssets, assetId].toString()];

        if (cacheCtx != null) {
          stepInputAsset = assetId;
          stepInputAmount = cacheCtx.amount;

          routeAssets = [...cacheCtx.routeAssets];
          routeIds = [...cacheCtx.routeIds];
          amount = cacheCtx.amount;
          funds = cacheCtx.funds;
          priceImpact = cacheCtx.priceImpact;
          continue;
        }

        final pair = cacheGetPair(stepInputAsset, assetId);

        if (pair == null || pair.pair.routeId == null) break;

        final transaction = cacheSwap(pair, stepInputAsset, stepInputAmount);

        if (transaction == null) break;

        stepInputAsset = assetId;
        stepInputAmount = transaction.amount;

        routeAssets.add(assetId);
        routeIds.add(pair.pair.routeId ?? 0);
        amount = transaction.amount;
        funds = transaction.funds;
        priceImpact = (Decimal.one + priceImpact) *
                (Decimal.one + transaction.priceImpact) -
            Decimal.one;
        final ctx = RouteCtx(
          routeAssets: [...routeAssets],
          routeIds: [...routeIds],
          amount: amount,
          funds: funds,
          priceImpact: priceImpact,
        );
        caches[routeAssets.toString()] = ctx;
      }
      if (stepInputAsset == outputAsset) {
        final ctx = RouteCtx(
          routeAssets: [...routeAssets],
          routeIds: [...routeIds],
          amount: amount,
          funds: funds,
          priceImpact: priceImpact,
        );

        bestRoute ??= ctx;

        if (bestRoute.amount < ctx.amount) {
          bestRoute = ctx;
        }
      }
    }

    return bestRoute;
  }

  // RouteCtx? getRoutesReverse(
  //     String inputAsset, String outputAsset, Decimal outputAmount) {
  //   const deep = 4;
  //   List<RouteQueueItem> queue = [];
  //   RouteCtx? bestRoute = null;

  //   queue.add(RouteQueueItem(
  //     key: outputAsset,
  //     ctx: RouteCtx(
  //       routeAssets: [outputAsset],
  //       routeIds: [],
  //       amount: Decimal.zero,
  //       funds: Decimal.zero,
  //       priceImpact: Decimal.zero,
  //     ),
  //   ));

  //   while (queue.length > 0) {
  //     final current = queue.removeLast();
  //     final stepOutputAmount =
  //         current.ctx.funds > Decimal.zero ? current.ctx.funds : outputAmount;
  //     final neibors = routes[current.key] ?? [];

  //     neibors.forEach((neibor) {
  //       if (current.ctx.routeIds.length == deep - 1 && neibor != inputAsset) {
  //         return;
  //       }

  //       final pair = getPair(current.key, neibor);
  //       if (pair == null) return;
  //       if (current.ctx.routeIds.indexOf(pair.pair.routeId ?? 0) > -1) return;

  //       final transaction = swapReverse(pair, neibor, stepOutputAmount);

  //       if (transaction == null) return;

  //       List<String> routeAssets = List.from(current.ctx.routeAssets);
  //       routeAssets.insert(0, neibor);

  //       List<int> routeIds = List.from(current.ctx.routeIds);
  //       routeIds.insert(0, pair.pair.routeId ?? 0);

  //       RouteCtx newCtx = RouteCtx(
  //         routeAssets: routeAssets,
  //         routeIds: routeIds,
  //         amount: transaction.amount,
  //         funds: transaction.funds,
  //         priceImpact: (Decimal.one + current.ctx.priceImpact) *
  //                 (Decimal.one + transaction.priceImpact) -
  //             Decimal.one,
  //       );

  //       if (neibor == inputAsset) {
  //         if (bestRoute == null ||
  //             (bestRoute?.funds ?? Decimal.zero) > newCtx.funds) {
  //           bestRoute = newCtx;
  //         }

  //         return;
  //       }

  //       if (newCtx.routeAssets.length < deep ||
  //           (newCtx.routeAssets.length == deep && neibor == inputAsset)) {
  //         queue.add(RouteQueueItem(key: neibor, ctx: newCtx));
  //       }
  //     });
  //   }

  //   return bestRoute;
  // }

  SwapResult? swap(RoutePair pair, String inputAsset, Decimal inputAmount) {
    var dy = Decimal.zero;
    var priceImpact = Decimal.zero;
    final dx = inputAmount * pair.fillPercent;

    var x = pair.baseAmount;
    var y = pair.quoteAmount;

    final inputBaseAsset = inputAsset == pair.pair.baseAssetId;

    if (!inputBaseAsset) {
      x = pair.quoteAmount;
      y = pair.baseAmount;
    }

    if (pair.pair.swapMethod == 'curve') {
      dy = curve.swap(x: x, y: y, dx: dx);
      priceImpact = curve.getPriceImpact(inputAmount, dy);
    } else {
      dy = uniswap.swap(x: x, y: y, dx: dx);
      priceImpact = uniswap.getPriceImpact(x, y, inputAmount, dy);
    }

    if (dy <= Decimal.zero) return null;

    return SwapResult(
      funds: inputAmount,
      amount: dy,
      priceImpact: priceImpact,
    );
  }

  // SwapResult? swapReverse(
  //     RoutePair pair, String inputAsset, Decimal outputAmount) {
  //   var dx = Decimal.zero;
  //   var priceImpact = Decimal.zero;

  //   final dy = outputAmount;

  //   var x = pair.baseAmount;
  //   var y = pair.quoteAmount;

  //   final inputBaseAsset = inputAsset == pair.pair.baseAssetId;

  //   if (!inputBaseAsset) {
  //     x = pair.quoteAmount;
  //     y = pair.baseAmount;
  //   }

  //   if (dy > y) return null;

  //   if (pair.pair.swapMethod == 'curve') {
  //     dx = curve.swapReverse(x: x, y: y, dy: dy);
  //     dx = (dx / pair.fillPercent).toDecimal(scaleOnInfinitePrecision: 8);
  //     priceImpact = curve.getPriceImpact(dx, outputAmount);
  //   } else {
  //     dx = uniswap.swapReverse(x: x, y: y, dy: dy);
  //     dx = (dx / pair.fillPercent).toDecimal(scaleOnInfinitePrecision: 8);
  //     priceImpact = uniswap.getPriceImpact(x, y, dx, outputAmount);
  //   }

  //   if (dx <= Decimal.zero) return null;
  //   return SwapResult(
  //     funds: dx,
  //     amount: outputAmount,
  //     priceImpact: priceImpact,
  //   );
  // }

  void _getAssetIds(
    List<String> retval,
    List<String> queue,
    Map<String, int> deepMap,
    int deep,
    String id,
  ) {
    routes[id]?.forEach((neibor) {
      if (retval.contains(neibor)) {
        return;
      }
      if (id == neibor) {
        return;
      }
      queue.add(neibor);
      deepMap[neibor] = deep;
      retval.add(neibor);
    });
  }

  List<String> getAssetIds(String id) {
    final retval = <String>[];
    final queue = <String>[];
    final deepMap = <String, int>{};
    queue.add(id);
    deepMap[id] = 0;
    var deep = 4;
    var assetId = '';

    while (queue.isNotEmpty) {
      assetId = queue.removeAt(0);
      deep = deepMap[assetId] ?? 4;
      if (deep > 3) {
        break;
      }

      _getAssetIds(retval, queue, deepMap, deep + 1, assetId);
    }
    return retval;
  }

  void _getRouteAssetIds(
    List<List<String>> retval,
    List<List<String>> queue,
    List<String> current,
    String input,
    String output,
  ) {
    routes[current.last]?.forEach((neibor) {
      if (neibor == input) {
        return;
      }

      final ids = [...current, neibor];
      if (neibor == output) {
        ids.removeAt(0);
        retval.add(ids);
        return;
      }
      queue.add(ids);
    });
  }

  List<List<String>> getRouteAssetIds(String input, String output) {
    final cache = cacheRouteAssetIds['$input $output'];
    if (cache != null && cache.isNotEmpty) {
      return cache;
    }

    final retval = <List<String>>[];
    final queue = <List<String>>[];
    var current = <String>[];
    queue.add([input]);

    var deep = 0;

    while (queue.isNotEmpty) {
      current = queue.removeAt(0);
      deep = current.length;

      if (deep > 4) {
        continue;
      }

      _getRouteAssetIds(retval, queue, current, input, output);
    }
    cacheRouteAssetIds['$input $output'] = [...retval];
    return retval;
  }
}

Pair? getPairByIds(List<Pair> pairs, String base, String quote) {
  final idx = pairs.indexWhere((pair) {
    final pair1 = pair.baseAssetId == base && pair.quoteAssetId == quote;
    final pair2 = pair.baseAssetId == quote && pair.quoteAssetId == base;
    return pair1 || pair2;
  });

  if (idx == -1) {
    return null;
  }
  return pairs[idx];
}

class PreOrderMeta with EquatableMixin {
  PreOrderMeta({
    required Asset inputAsset,
    required Asset outputAsset,
    required List<Pair> pairs,
    required List<Asset> assets,
    required Decimal amount,
    required Decimal funds,
    required this.order,
  }) {
    final inputSymbol = inputAsset.symbol ?? '';
    final outputSymbol = outputAsset.symbol ?? '';
    const slippage = 0.99;

    // calc price and reverse price text
    price = Decimal.zero;
    priceText = '';
    reversePrice = Decimal.zero;
    reversePriceText = '';

    if (amount > Decimal.zero && funds > Decimal.zero) {
      price = (amount / funds).toDecimal(scaleOnInfinitePrecision: 8);
      reversePrice = (funds / amount).toDecimal(scaleOnInfinitePrecision: 8);
      priceText = '1 $inputSymbol ≈ ${price.toString()} $outputSymbol';
      reversePriceText =
          '1 $outputSymbol ≈ ${reversePrice.toString()} $inputSymbol';
    }

    // calc fee and fee text
    fee = Decimal.zero;
    feeText = '';
    var receivePercent = Decimal.one;
    for (var i = 0; i < order.ctx.routeAssets.length - 1; i++) {
      final pair = getPairByIds(
          pairs, order.ctx.routeAssets[i], order.ctx.routeAssets[i + 1]);
      if (pair == null) {
        break;
      }
      receivePercent =
          receivePercent * (Decimal.one - pair.feePercent.asDecimal);
    }

    fee = funds - receivePercent * funds;
    feeText = fee.toString();

    // calc min recevied
    minReceived = amount * slippage.asDecimal;
    minReceivedText = minReceived.toString();
    routes = '';

    order.ctx.routeAssets.forEach((id) {
      final asset = getAssetById(assets, id);
      var chainSymbol = '';
      if (asset.symbol == 'USDT') {
        if (asset.chainSymbol == 'ETH') {
          chainSymbol = '@ERC20';
        }
        if (asset.chainSymbol == 'TRX') {
          chainSymbol = '@TRC20';
        }
      }
      routes = '$routes ${asset.symbol}$chainSymbol ->';
    });

    routes = routes.substring(0, routes.length - 3);
  }
  PreOrder order;
  late Decimal price;
  late String priceText;
  late Decimal reversePrice;
  late String reversePriceText;
  late Decimal fee;
  late String feeText;
  late Decimal minReceived;
  late String minReceivedText;
  late String routes;

  @override
  List<Object?> get props => [
        order,
        price,
        priceText,
        reversePrice,
        reversePriceText,
        fee,
        feeText,
        minReceived,
        minReceivedText,
        routes,
      ];
}
