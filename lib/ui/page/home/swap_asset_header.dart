import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../util/extension/extension.dart';
import '../../../util/r.dart';
import '../../../util/swap_asset.dart';
import '../../../util/swap_pair.dart';

// sort type for swapAssets.
const kQueryParameterSort = 'sort';

// sort type for swapAssets.
const kQueryParameterSortName = 'name';

enum SwapAssetSortType {
  none,
  increase,
  decrease,
}

enum SwapAssetSortName {
  price,
  volume24h,
  liquidity,
  turnOver,
}

enum SwapAssetHeaderType {
  swapAssets,
  pool,
}

class SwapAssetHeader extends StatelessWidget {
  const SwapAssetHeader({
    Key? key,
    required this.sortType,
    required this.sortName,
    required this.type,
  }) : super(key: key);

  final SwapAssetSortType sortType;
  final SwapAssetSortName sortName;
  final SwapAssetHeaderType type;

  void updateSortType(BuildContext context, SwapAssetSortName name) {
    final params = Map<String, String>.from(context.queryParameters);
    if (name == sortName) {
      params[kQueryParameterSort] = sortType.next.name;
    } else {
      params[kQueryParameterSortName] = name.name;
      params[kQueryParameterSort] = SwapAssetSortType.none.name;
    }
    context.replace(Uri(path: context.path).replace(queryParameters: params));
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 40,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 8),
            if (SwapAssetHeaderType.swapAssets == type)
              ActionChip(
                  label: Row(children: [
                    Text(context.l10n.price),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 6,
                      height: 10,
                      child: SwapAssetSortName.price == sortName
                          ? SvgPicture.asset(sortType.iconSwapAssetName)
                          : Container(),
                    ),
                  ]),
                  backgroundColor:
                      SwapAssetSortName.price == sortName ? Colors.grey : null,
                  onPressed: () {
                    updateSortType(context, SwapAssetSortName.price);
                  })
            else
              ActionChip(
                  label: Row(children: [
                    Text(context.l10n.liquidity),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 6,
                      height: 10,
                      child: SwapAssetSortName.liquidity == sortName
                          ? SvgPicture.asset(sortType.iconSwapAssetName)
                          : Container(),
                    ),
                  ]),
                  backgroundColor: SwapAssetSortName.liquidity == sortName
                      ? Colors.grey
                      : null,
                  onPressed: () {
                    updateSortType(context, SwapAssetSortName.liquidity);
                  }),
            const SizedBox(width: 8),
            ActionChip(
                label: Row(children: [
                  Text(context.l10n.volume),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 6,
                    height: 10,
                    child: SwapAssetSortName.volume24h == sortName
                        ? SvgPicture.asset(sortType.iconSwapAssetName)
                        : Container(),
                  ),
                ]),
                backgroundColor: SwapAssetSortName.volume24h == sortName
                    ? Colors.grey
                    : null,
                onPressed: () {
                  updateSortType(context, SwapAssetSortName.volume24h);
                }),
            const SizedBox(width: 8),
            if (SwapAssetHeaderType.swapAssets == type)
              ActionChip(
                  label: Row(children: [
                    Text(context.l10n.liquidity),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 6,
                      height: 10,
                      child: SwapAssetSortName.liquidity == sortName
                          ? SvgPicture.asset(sortType.iconSwapAssetName)
                          : Container(),
                    ),
                  ]),
                  backgroundColor: SwapAssetSortName.liquidity == sortName
                      ? Colors.grey
                      : null,
                  onPressed: () {
                    updateSortType(context, SwapAssetSortName.liquidity);
                  })
            else
              ActionChip(
                  label: Row(children: [
                    Text(context.l10n.turnover),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 6,
                      height: 10,
                      child: SwapAssetSortName.turnOver == sortName
                          ? SvgPicture.asset(sortType.iconSwapAssetName)
                          : Container(),
                    ),
                  ]),
                  backgroundColor: SwapAssetSortName.turnOver == sortName
                      ? Colors.grey
                      : null,
                  onPressed: () {
                    updateSortType(context, SwapAssetSortName.turnOver);
                  }),
          ],
        ),
      );
}

extension SortTypeExt on SwapAssetSortType {
  String get iconSwapAssetName {
    switch (this) {
      case SwapAssetSortType.none:
        return R.resourcesAmplitudeNoneSvg;
      case SwapAssetSortType.increase:
        return R.resourcesAmplitudeIncreaseSvg;
      case SwapAssetSortType.decrease:
        return R.resourcesAmplitudeDecreaseSvg;
    }
  }

  SwapAssetSortType get next {
    switch (this) {
      case SwapAssetSortType.none:
        return SwapAssetSortType.increase;
      case SwapAssetSortType.increase:
        return SwapAssetSortType.decrease;
      case SwapAssetSortType.decrease:
        return SwapAssetSortType.none;
    }
  }
}

extension SortSwapAssets on List<SwapAssetMeta> {
  void sortBy(SwapAssetSortName name, SwapAssetSortType sort) {
    switch (name) {
      case SwapAssetSortName.price:
        switch (sort) {
          case SwapAssetSortType.increase:
            this.sort((a, b) => a.swapAsset.price.asDecimal
                .compareTo(b.swapAsset.price.asDecimal));
            break;
          case SwapAssetSortType.decrease:
            this.sort((a, b) => b.swapAsset.price.asDecimal
                .compareTo(a.swapAsset.price.asDecimal));
            break;
          case SwapAssetSortType.none:
            break;
        }
        break;
      case SwapAssetSortName.volume24h:
        switch (sort) {
          case SwapAssetSortType.increase:
            this.sort((a, b) => a.volume.compareTo(b.volume));
            break;
          case SwapAssetSortType.decrease:
            this.sort((a, b) => b.volume.compareTo(a.volume));
            break;
          case SwapAssetSortType.none:
            break;
        }
        break;
      case SwapAssetSortName.liquidity:
        switch (sort) {
          case SwapAssetSortType.increase:
            this.sort(
                (a, b) => a.liquidityWithPrice.compareTo(b.liquidityWithPrice));
            break;
          case SwapAssetSortType.decrease:
            this.sort(
                (a, b) => b.liquidityWithPrice.compareTo(a.liquidityWithPrice));
            break;
          case SwapAssetSortType.none:
            break;
        }
        break;
      case SwapAssetSortName.turnOver:
        break;
    }
  }
}

extension SortSwapPairs on List<SwapPairMeta> {
  void sortBy(SwapAssetSortName name, SwapAssetSortType sort) {
    switch (name) {
      case SwapAssetSortName.turnOver:
        switch (sort) {
          case SwapAssetSortType.increase:
            this.sort((a, b) => a.turnOver.compareTo(b.turnOver));
            break;
          case SwapAssetSortType.decrease:
            this.sort((a, b) => b.turnOver.compareTo(a.turnOver));
            break;
          case SwapAssetSortType.none:
            break;
        }
        break;
      case SwapAssetSortName.volume24h:
        switch (sort) {
          case SwapAssetSortType.increase:
            this.sort((a, b) => a.swapPair.volume24h.asDecimal
                .compareTo(b.swapPair.volume24h.asDecimal));
            break;
          case SwapAssetSortType.decrease:
            this.sort((a, b) => b.swapPair.volume24h.asDecimal
                .compareTo(a.swapPair.volume24h.asDecimal));
            break;
          case SwapAssetSortType.none:
            break;
        }
        break;
      case SwapAssetSortName.liquidity:
        switch (sort) {
          case SwapAssetSortType.increase:
            this.sort((a, b) => a.volume.compareTo(b.volume));
            break;
          case SwapAssetSortType.decrease:
            this.sort((a, b) => b.volume.compareTo(a.volume));
            break;
          case SwapAssetSortType.none:
            break;
        }
        break;
      case SwapAssetSortName.price:
        break;
    }
  }
}
