import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../util/asset.dart';
import '../../../util/extension/extension.dart';
import '../../../util/pair.dart';
import '../../../util/r.dart';

// sort type for assets.
const kQueryParameterSort = 'sort';

// sort type for assets.
const kQueryParameterSortName = 'name';

enum AssetSortType {
  none,
  increase,
  decrease,
}

enum AssetSortName {
  price,
  volume24h,
  liquidity,
  turnOver,
}

enum AssetHeaderType {
  assets,
  pool,
}

class AssetHeader extends StatelessWidget {
  const AssetHeader({
    Key? key,
    required this.sortType,
    required this.sortName,
    required this.type,
  }) : super(key: key);

  final AssetSortType sortType;
  final AssetSortName sortName;
  final AssetHeaderType type;

  void updateSortType(BuildContext context, AssetSortName name) {
    final params = Map<String, String>.from(context.queryParameters);
    if (name == sortName) {
      params[kQueryParameterSort] = sortType.next.name;
    } else {
      params[kQueryParameterSortName] = name.name;
      params[kQueryParameterSort] = AssetSortType.none.name;
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
            if (AssetHeaderType.assets == type)
              ActionChip(
                  label: Row(children: [
                    const Text('Price'),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 6,
                      height: 10,
                      child: AssetSortName.price == sortName
                          ? SvgPicture.asset(sortType.iconAssetName)
                          : Container(),
                    ),
                  ]),
                  backgroundColor:
                      AssetSortName.price == sortName ? Colors.grey : null,
                  onPressed: () {
                    updateSortType(context, AssetSortName.price);
                  })
            else
              ActionChip(
                  label: Row(children: [
                    const Text('Liquidity'),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 6,
                      height: 10,
                      child: AssetSortName.liquidity == sortName
                          ? SvgPicture.asset(sortType.iconAssetName)
                          : Container(),
                    ),
                  ]),
                  backgroundColor:
                      AssetSortName.liquidity == sortName ? Colors.grey : null,
                  onPressed: () {
                    updateSortType(context, AssetSortName.liquidity);
                  }),
            const SizedBox(width: 8),
            ActionChip(
                label: Row(children: [
                  const Text('24h Volume'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 6,
                    height: 10,
                    child: AssetSortName.volume24h == sortName
                        ? SvgPicture.asset(sortType.iconAssetName)
                        : Container(),
                  ),
                ]),
                backgroundColor:
                    AssetSortName.volume24h == sortName ? Colors.grey : null,
                onPressed: () {
                  updateSortType(context, AssetSortName.volume24h);
                }),
            const SizedBox(width: 8),
            if (AssetHeaderType.assets == type)
              ActionChip(
                  label: Row(children: [
                    const Text('Liquidity'),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 6,
                      height: 10,
                      child: AssetSortName.liquidity == sortName
                          ? SvgPicture.asset(sortType.iconAssetName)
                          : Container(),
                    ),
                  ]),
                  backgroundColor:
                      AssetSortName.liquidity == sortName ? Colors.grey : null,
                  onPressed: () {
                    updateSortType(context, AssetSortName.liquidity);
                  })
            else
              ActionChip(
                  label: Row(children: [
                    const Text('24h Turnover'),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 6,
                      height: 10,
                      child: AssetSortName.turnOver == sortName
                          ? SvgPicture.asset(sortType.iconAssetName)
                          : Container(),
                    ),
                  ]),
                  backgroundColor:
                      AssetSortName.turnOver == sortName ? Colors.grey : null,
                  onPressed: () {
                    updateSortType(context, AssetSortName.turnOver);
                  }),
          ],
        ),
      );
}

extension SortTypeExt on AssetSortType {
  String get iconAssetName {
    switch (this) {
      case AssetSortType.none:
        return R.resourcesAmplitudeNoneSvg;
      case AssetSortType.increase:
        return R.resourcesAmplitudeIncreaseSvg;
      case AssetSortType.decrease:
        return R.resourcesAmplitudeDecreaseSvg;
    }
  }

  AssetSortType get next {
    switch (this) {
      case AssetSortType.none:
        return AssetSortType.increase;
      case AssetSortType.increase:
        return AssetSortType.decrease;
      case AssetSortType.decrease:
        return AssetSortType.none;
    }
  }
}

extension SortAssets on List<AssetMeta> {
  void sortBy(AssetSortName name, AssetSortType sort) {
    switch (name) {
      case AssetSortName.price:
        switch (sort) {
          case AssetSortType.increase:
            this.sort((a, b) =>
                a.asset.price.asDecimal.compareTo(b.asset.price.asDecimal));
            break;
          case AssetSortType.decrease:
            this.sort((a, b) =>
                b.asset.price.asDecimal.compareTo(a.asset.price.asDecimal));
            break;
          case AssetSortType.none:
            break;
        }
        break;
      case AssetSortName.volume24h:
        switch (sort) {
          case AssetSortType.increase:
            this.sort((a, b) => a.volume.compareTo(b.volume));
            break;
          case AssetSortType.decrease:
            this.sort((a, b) => b.volume.compareTo(a.volume));
            break;
          case AssetSortType.none:
            break;
        }
        break;
      case AssetSortName.liquidity:
        switch (sort) {
          case AssetSortType.increase:
            this.sort(
                (a, b) => a.liquidityWithPrice.compareTo(b.liquidityWithPrice));
            break;
          case AssetSortType.decrease:
            this.sort(
                (a, b) => b.liquidityWithPrice.compareTo(a.liquidityWithPrice));
            break;
          case AssetSortType.none:
            break;
        }
        break;
      case AssetSortName.turnOver:
        break;
    }
  }
}

extension SortPairs on List<PairMeta> {
  void sortBy(AssetSortName name, AssetSortType sort) {
    switch (name) {
      case AssetSortName.turnOver:
        switch (sort) {
          case AssetSortType.increase:
            this.sort((a, b) => a.turnOver.compareTo(b.turnOver));
            break;
          case AssetSortType.decrease:
            this.sort((a, b) => b.turnOver.compareTo(a.turnOver));
            break;
          case AssetSortType.none:
            break;
        }
        break;
      case AssetSortName.volume24h:
        switch (sort) {
          case AssetSortType.increase:
            this.sort((a, b) => a.pair.volume24h.asDecimal
                .compareTo(b.pair.volume24h.asDecimal));
            break;
          case AssetSortType.decrease:
            this.sort((a, b) => b.pair.volume24h.asDecimal
                .compareTo(a.pair.volume24h.asDecimal));
            break;
          case AssetSortType.none:
            break;
        }
        break;
      case AssetSortName.liquidity:
        switch (sort) {
          case AssetSortType.increase:
            this.sort((a, b) => a.volume.compareTo(b.volume));
            break;
          case AssetSortType.decrease:
            this.sort((a, b) => b.volume.compareTo(a.volume));
            break;
          case AssetSortType.none:
            break;
        }
        break;
      case AssetSortName.price:
        break;
    }
  }
}
