import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:hashids2/hashids2.dart';
import 'package:memoized/memoized.dart';

import './extension/extension.dart';
import '../db/mixin_database.dart';

class SwapPairOverview {
  SwapPairOverview() {
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

  void plus(SwapPair swapPair) {
    volume24h += swapPair.volume24h.asDecimal;
    totalUSDValue +=
        swapPair.baseValue.asDecimal + swapPair.quoteValue.asDecimal;
    fee24h += swapPair.fee24h.asDecimal;
    transactions += swapPair.transactionCount24h ?? 0;
    turnOver =
        (volume24h / totalUSDValue).toDecimal(scaleOnInfinitePrecision: 8);
  }
}

SwapAsset getSwapAssetById(List<SwapAsset> swapAssets, String id) =>
    swapAssets.firstWhere((swapAsset) => swapAsset.id == id);

class SwapPairMeta {
  SwapPairMeta(this.swapPair, List<SwapAsset> swapAssets) {
    const priorities = ['XIN', 'ETH', 'BTC', 'DAI', 'USDC', 'pUSD', 'USDT'];
    baseSwapAsset = getSwapAssetById(swapAssets, swapPair.baseAssetId);
    quoteSwapAsset = getSwapAssetById(swapAssets, swapPair.quoteAssetId);

    final baseIndex = priorities.indexOf(baseSwapAsset.symbol ?? '');
    final quoteIndex = priorities.indexOf(quoteSwapAsset.symbol ?? '');
    reverse = quoteIndex < baseIndex;
    if (reverse) {
      swapPair = getReverseSwapPair(swapPair);
      final tmpSwapAsset = baseSwapAsset;
      baseSwapAsset = quoteSwapAsset;
      quoteSwapAsset = tmpSwapAsset;
    }

    price = getSwapPairPrice(swapPair, reverse: false);
    reversePrice = getSwapPairPrice(swapPair, reverse: true);

    final baseSymbol = baseSwapAsset.symbol;
    final quoteSymbol = quoteSwapAsset.symbol;

    symbol = '$baseSymbol / $quoteSymbol';

    volume = swapPair.quoteValue.asDecimal + swapPair.baseValue.asDecimal;
    turnOver = Decimal.zero;
    if (volume > Decimal.zero) {
      turnOver = (swapPair.volume24h.asDecimal / volume)
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
  SwapPair swapPair;
  late bool reverse;
  late Decimal price;
  late Decimal reversePrice;
  late String symbol;
  late Decimal volume;
  late Decimal turnOver;
  late String priceText;
  late String reversePriceText;
  late SwapAsset baseSwapAsset;
  late SwapAsset quoteSwapAsset;
  // late SwapAsset liquiditySwapAsset;
}

List<SwapPairMeta> makeSwapPairMeta(
    List<SwapPair> swapPairs, List<SwapAsset> swapAssets) {
  if (swapAssets.isNotEmpty) {
    return swapPairs
        .map((swapPair) => SwapPairMeta(swapPair, swapAssets))
        .toList();
  } else {
    return [];
  }
}

SwapPair getReverseSwapPair(SwapPair swapPair) => SwapPair(
      quoteAmount: swapPair.baseAmount,
      quoteAssetId: swapPair.baseAssetId,
      quoteValue: swapPair.baseValue,
      quoteVolume24h: swapPair.baseVolume24h,
      // quoteSymbol: swapPair.baseSymbol,
      // quoteLogo: swapPair.baseLogo,
      // quoteName: swapPair.baseName,
      baseAmount: swapPair.quoteAmount,
      baseAssetId: swapPair.quoteAssetId,
      baseValue: swapPair.quoteValue,
      baseVolume24h: swapPair.quoteVolume24h,
      // baseSymbol: swapPair.quoteSymbol,
      // baseLogo: swapPair.quoteLogo,
      // baseName: swapPair.quoteName,
      fee24h: swapPair.fee24h,
      feePercent: swapPair.feePercent,
      liquidity: swapPair.liquidity,
      liquidityAssetId: swapPair.liquidityAssetId,
      maxLiquidity: swapPair.maxLiquidity,
      routeId: swapPair.routeId,
      transactionCount24h: swapPair.transactionCount24h,
      version: swapPair.version,
      volume24h: swapPair.volume24h,
      // liquiditySymbol: swapPair.liquiditySymbol,
      // liquidityLogo: swapPair.liquidityLogo,
      // liquidityName: swapPair.liquidityName,
    );

Decimal getUniSwapPairPrice(SwapPair swapPair, {bool reverse = false}) {
  final baseAmount = swapPair.baseAmount.asDecimal;
  final quoteAmount = swapPair.quoteAmount.asDecimal;
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

Decimal getCurveSwapPairPrice(SwapPair swapPair, {bool reverse = false}) {
  final curve = Curve(A.asDecimal);
  final fillPercent = Decimal.one - swapPair.feePercent.asDecimal;
  final baseAmount = swapPair.baseAmount.asDecimal;
  final quoteAmount = swapPair.quoteAmount.asDecimal;

  if (reverse) {
    return curve.swapReverse(
      x: baseAmount,
      y: quoteAmount,
      dy: fillPercent,
    );
  }

  return curve.swap(x: baseAmount, y: quoteAmount, dx: fillPercent);
}

Decimal getSwapPairPrice(SwapPair swapPair, {bool reverse = false}) =>
    swapPair.swapMethod == 'curve'
        ? getCurveSwapPairPrice(swapPair, reverse: reverse)
        : getUniSwapPairPrice(swapPair, reverse: reverse);

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
  // k is liquidity of swapPair
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
    required this.inputSwapAsset,
    required this.outputSwapAsset,
    required this.inputAmount,
    required this.inputScale,
  });
  String inputSwapAsset;
  String outputSwapAsset;
  String inputAmount;
  String inputScale;
}

class RouteCtx with EquatableMixin {
  const RouteCtx({
    required this.routeSwapAssets,
    required this.routeIds,
    required this.amount,
    required this.funds,
    required this.priceImpact,
  });
  final List<String> routeSwapAssets;
  final List<int> routeIds;
  final Decimal amount;
  final Decimal funds;
  final Decimal priceImpact;

  @override
  List<Object?> get props => [
        routeSwapAssets,
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

class PreOrderResult {
  PreOrderResult({this.preOrder, this.error});
  String? error;
  PreOrder? preOrder;
}

class RouteQueueItem {
  RouteQueueItem({
    required this.key,
    required this.ctx,
  });
  RouteCtx ctx;
  String key;
}

class RouteSwapPair {
  RouteSwapPair({
    required this.swapPair,
    required this.K,
    required this.baseAmount,
    required this.quoteAmount,
    required this.fillPercent,
    required this.D,
  });
  SwapPair swapPair;
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

class SwapPairRoutes {
  SwapPairRoutes() {
    curve = Curve(A.asDecimal);
    uniswap = const Uniswap();
    hashids = HashIds(salt: hashSalt);
    cacheGetSwapPair = Memoized2(getSwapPair);
  }
  List<RouteSwapPair> swapPairs = [];
  Map<String, List<String>> routes = {};
  Map<String, List<List<String>>> cacheRouteAssetIds = {};
  late Uniswap uniswap;
  late Curve curve;
  late HashIds hashids;
  late Memoized2<RouteSwapPair?, String, String> cacheGetSwapPair;

  void makeRoutes(List<SwapPair> swapPairs) {
    this.swapPairs = swapPairs.map((p) {
      final baseAmount = p.baseAmount.asDecimal;
      final quoteAmount = p.quoteAmount.asDecimal;
      final fillPercent = Decimal.one - p.feePercent.asDecimal;

      var d = Decimal.zero;
      if (p.swapMethod == 'curve') {
        d = curve
            .getD([baseAmount * 10e8.asDecimal, quoteAmount * 10e8.asDecimal]);
      }

      return RouteSwapPair(
        swapPair: p,
        baseAmount: baseAmount,
        quoteAmount: quoteAmount,
        fillPercent: fillPercent,
        K: baseAmount * quoteAmount,
        D: d,
      );
    }).toList();

    this.swapPairs.forEach((swapPair) {
      setSwapAssetRoute(swapPair.swapPair.baseAssetId, swapPair);
      setSwapAssetRoute(swapPair.swapPair.quoteAssetId, swapPair);
    });
  }

  void setSwapAssetRoute(String swapAsset, RouteSwapPair swapPair) {
    final routes = this.routes[swapAsset] ?? [];
    final opposit = getOppositeSwapAsset(swapPair, swapAsset);

    if (!routes.contains(opposit)) {
      routes.add(opposit);
      this.routes[swapAsset] = routes;
    }
  }

  RouteSwapPair? getSwapPair(String base, String quote) {
    final idx = swapPairs.indexWhere((p) {
      final swapPair1 =
          p.swapPair.baseAssetId == base && p.swapPair.quoteAssetId == quote;
      final swapPair2 =
          p.swapPair.baseAssetId == quote && p.swapPair.quoteAssetId == base;
      return swapPair1 || swapPair2;
    });

    if (idx == -1) {
      return null;
    }
    return swapPairs[idx];
  }

  RouteSwapPair? getSwapPairByRouteId(int id) {
    final idx = swapPairs.indexWhere((p) => p.swapPair.routeId == id);
    if (idx == -1) {
      return null;
    }
    return swapPairs[idx];
  }

  String getOppositeSwapAsset(RouteSwapPair swapPair, String input) =>
      input == swapPair.swapPair.baseAssetId
          ? swapPair.swapPair.quoteAssetId
          : swapPair.swapPair.baseAssetId;

  PreOrderResult getPreOrder(SwapParams params) {
    final funds = params.inputAmount;

    if (funds.asDecimal <= Decimal.zero) {
      return PreOrderResult(error: 'swap.error.input-amount-invalid');
    }

    final input =
        funds.asDecimal * (1 / double.parse(params.inputScale)).asDecimal;

    final bestRoute =
        getRoutes(params.inputSwapAsset, params.outputSwapAsset, input);

    if (bestRoute == null) {
      return PreOrderResult(error: 'swap.error.no-swapPair-route-found');
    }

    final amount = bestRoute.amount * params.inputScale.asDecimal;

    if (amount <= Decimal.zero) {
      return PreOrderResult(error: 'swap.error.swap-amount-not-support');
    }

    return PreOrderResult(
      preOrder: PreOrder(
        ctx: bestRoute,
        amount: amount.round(scale: 8).toString(),
        funds: funds,
        fillAssetId: params.outputSwapAsset,
        payAssetId: params.inputSwapAsset,
        routes: hashids.encode(bestRoute.routeIds),
        state: 'Done',
      ),
    );
  }

  RouteCtx? getRoutes(
      String inputSwapAsset, String outputSwapAsset, Decimal inputAmount) {
    final queue = getRouteAssetIds(inputSwapAsset, outputSwapAsset);
    RouteCtx? bestRoute;

    final cacheSwap = Memoized3(swap);
    final caches = <String, RouteCtx>{};

    while (queue.isNotEmpty) {
      final assetIdList = queue.removeLast();

      var stepInputAmount = inputAmount;
      var stepInputSwapAsset = inputSwapAsset;

      var routeSwapAssets = [inputSwapAsset];
      var routeIds = <int>[];
      var amount = Decimal.zero;
      var funds = Decimal.zero;
      var priceImpact = Decimal.zero;
      var assetId = '';
      var startIdx = 0;

      final queue2 = [inputSwapAsset, ...assetIdList];

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

        final cacheCtx = caches[[...routeSwapAssets, assetId].toString()];

        if (cacheCtx != null) {
          stepInputSwapAsset = assetId;
          stepInputAmount = cacheCtx.amount;

          routeSwapAssets = [...cacheCtx.routeSwapAssets];
          routeIds = [...cacheCtx.routeIds];
          amount = cacheCtx.amount;
          funds = cacheCtx.funds;
          priceImpact = cacheCtx.priceImpact;
          continue;
        }

        final swapPair = cacheGetSwapPair(stepInputSwapAsset, assetId);

        if (swapPair == null || swapPair.swapPair.routeId == null) break;

        final transaction =
            cacheSwap(swapPair, stepInputSwapAsset, stepInputAmount);

        if (transaction == null) break;

        stepInputSwapAsset = assetId;
        stepInputAmount = transaction.amount;

        routeSwapAssets.add(assetId);
        routeIds.add(swapPair.swapPair.routeId ?? 0);
        amount = transaction.amount;
        funds = transaction.funds;
        priceImpact = (Decimal.one + priceImpact) *
                (Decimal.one + transaction.priceImpact) -
            Decimal.one;
        final ctx = RouteCtx(
          routeSwapAssets: [...routeSwapAssets],
          routeIds: [...routeIds],
          amount: amount,
          funds: funds,
          priceImpact: priceImpact,
        );
        caches[routeSwapAssets.toString()] = ctx;
      }
      if (stepInputSwapAsset == outputSwapAsset) {
        final ctx = RouteCtx(
          routeSwapAssets: [...routeSwapAssets],
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

  SwapResult? swap(
      RouteSwapPair swapPair, String inputSwapAsset, Decimal inputAmount) {
    var dy = Decimal.zero;
    var priceImpact = Decimal.zero;
    final dx = inputAmount * swapPair.fillPercent;

    var x = swapPair.baseAmount;
    var y = swapPair.quoteAmount;

    final inputBaseSwapAsset = inputSwapAsset == swapPair.swapPair.baseAssetId;

    if (!inputBaseSwapAsset) {
      x = swapPair.quoteAmount;
      y = swapPair.baseAmount;
    }

    if (swapPair.swapPair.swapMethod == 'curve') {
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

SwapPair? getSwapPairByIds(
    List<SwapPair> swapPairs, String base, String quote) {
  final idx = swapPairs.indexWhere((swapPair) {
    final swapPair1 =
        swapPair.baseAssetId == base && swapPair.quoteAssetId == quote;
    final swapPair2 =
        swapPair.baseAssetId == quote && swapPair.quoteAssetId == base;
    return swapPair1 || swapPair2;
  });

  if (idx == -1) {
    return null;
  }
  return swapPairs[idx];
}

class PreOrderMeta with EquatableMixin {
  PreOrderMeta({
    required SwapAsset inputSwapAsset,
    required SwapAsset outputSwapAsset,
    required List<SwapPair> swapPairs,
    required List<SwapAsset> swapAssets,
    required this.amount,
    required this.funds,
    required this.order,
  }) {
    final inputSymbol = inputSwapAsset.symbol ?? '';
    final outputSymbol = outputSwapAsset.symbol ?? '';
    const slippage = 0.99;

    // calc price and reverse price text
    price = Decimal.zero;
    priceText = '';
    reversePrice = Decimal.zero;
    reversePriceText = '';

    if (amount > Decimal.zero && funds > Decimal.zero) {
      price = (amount / funds).toDecimal(scaleOnInfinitePrecision: 8);
      reversePrice = (funds / amount).toDecimal(scaleOnInfinitePrecision: 8);
      priceText = '1 $inputSymbol ≈ ${price.toStringAsFixed(8)} $outputSymbol';
      reversePriceText =
          '1 $outputSymbol ≈ ${reversePrice.toStringAsFixed(8)} $inputSymbol';
    }

    // calc fee and fee text
    fee = Decimal.zero;
    feeText = '';
    var receivePercent = Decimal.one;
    for (var i = 0; i < order.ctx.routeSwapAssets.length - 1; i++) {
      final swapPair = getSwapPairByIds(swapPairs, order.ctx.routeSwapAssets[i],
          order.ctx.routeSwapAssets[i + 1]);
      if (swapPair == null) {
        break;
      }
      receivePercent =
          receivePercent * (Decimal.one - swapPair.feePercent.asDecimal);
    }

    fee = funds - receivePercent * funds;
    feeText = fee.toStringAsFixed(8);

    // calc min recevied
    minReceived = amount * slippage.asDecimal;
    minReceivedText = minReceived.toStringAsFixed(8);
    routes = '';

    order.ctx.routeSwapAssets.forEach((id) {
      final swapAsset = getSwapAssetById(swapAssets, id);
      var chainSymbol = '';
      if (swapAsset.symbol == 'USDT') {
        if (swapAsset.chainSymbol == 'ETH') {
          chainSymbol = '@ERC20';
        }
        if (swapAsset.chainSymbol == 'TRX') {
          chainSymbol = '@TRC20';
        }
      }
      routes = '$routes ${swapAsset.symbol}$chainSymbol ->';
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
  final Decimal amount;
  final Decimal funds;

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
