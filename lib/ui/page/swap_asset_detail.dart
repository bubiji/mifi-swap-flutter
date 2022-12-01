import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:uniswap_sdk_dart/uniswap_sdk_dart.dart' as mifiswap;

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/swap_pair.dart';
import '../router/mixin_routes.dart';
import '../widget/account.dart';
import '../widget/symbol.dart';
import 'home/swap_asset_header.dart';
import 'home/tab_swap_pairs.dart';

// the selected tab.
const kQueryParameterTab = 'tab';

enum _Tab {
  swap,
  overview,
}

mifiswap.AssetExtra noAssetExtra() => mifiswap.AssetExtra(
      circulation: '',
      explorer: '',
      intro: {},
      issue: '',
      name: '',
      total: '',
      website: '',
    );

class SwapAssetDetail extends HookWidget {
  const SwapAssetDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final id = usePathParameter('id', path: swapAssetDetailPath);

    final sortParam =
        useQueryParameter(kQueryParameterSort, path: context.path);

    final sortNameParam =
        useQueryParameter(kQueryParameterSortName, path: context.path);

    final tabParam = useQueryParameter(kQueryParameterTab, path: context.path);
    final selectedTab = _Tab.values.byNameOrNull(tabParam) ?? _Tab.swap;

    final sortType = useMemoized(
        () =>
            SwapAssetSortType.values.byNameOrNull(sortParam) ??
            SwapAssetSortType.none,
        [sortParam]);

    final sortName = useMemoized(() {
      final name = selectedTab == _Tab.overview
          ? SwapAssetSortName.price
          : SwapAssetSortName.liquidity;
      return SwapAssetSortName.values.byNameOrNull(sortNameParam) ?? name;
    }, [sortNameParam, selectedTab]);

    final data = useMemoizedStream(
      () => context.appServices.mixinDatabase.swapAssetDao
          .get(id)
          .watchSingleOrNull(),
      keys: [id],
    ).data;

    if (data == null) {
      return const SizedBox();
    }

    final swapAssets = useMemoizedStream(
      () => context.appServices.mixinDatabase.swapAssetDao.getAll().watch(),
      initialData: <SwapAsset>[],
    ).requireData;

    final swapPairResults = useMemoizedStream(
      () => context.appServices.mixinDatabase.swapPairDao.getAll().watch(),
      initialData: <SwapPair>[],
    ).requireData;

    final swapPairs = useMemoized(
        () => swapPairResults
            .where((swapPair) =>
                id == swapPair.baseAssetId || id == swapPair.quoteAssetId)
            .toList(),
        [swapPairResults]);

    final swapPairMetas = useMemoized(
        () => makeSwapPairMeta(swapPairs, swapAssets), [swapPairs, swapAssets]);

    // final swapAssetMeta =
    //     useMemoized(() => SwapAssetMeta(data, swapPairs), [data, swapPairs]);

    useMemoized(() {
      if (selectedTab != _Tab.swap) {
        return;
      }
      swapPairMetas.sortBy(sortName, sortType);
    }, [swapPairMetas, sortName, sortType, selectedTab]);

    final overview = useMemoized(() {
      final overview = SwapPairOverview();
      swapPairs.forEach(overview.plus);
      return overview;
    }, [swapPairs]);

    final info = useMemoized(() {
      final info = data.extra;
      if (info == null) {
        return noAssetExtra();
      }
      return mifiswap.AssetExtra.fromJson(
          convert.jsonDecode(info) as Map<String, dynamic>);
    }, [data.extra]);

    Widget buildGrid() {
      final tiles = <Widget>[];
      for (final item in info.intro[Intl.defaultLocale] ?? <String>[]) {
        tiles.add(Text(item));
      }
      return Column(children: tiles);
    }

    return Scaffold(
      backgroundColor: context.theme.background,
      appBar: const TopAppBar(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
              child: Center(
                  child: Column(mainAxisSize: MainAxisSize.max, children: [
            SymbolIconWithBorder(
              symbolUrl: data.logo,
              size: 40,
              chainSize: 8,
              chainBorder: BorderSide(
                color: context.colorScheme.background,
                width: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ' ${data.name}'.overflow,
                    style: TextStyle(
                      color: context.colorScheme.thirdText,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.l10n.price,
                    style: TextStyle(
                      color: context.colorScheme.thirdText,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ]),
            const SizedBox(height: 10),
            Text(
              data.price.toFiat(),
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
          ]))),
          // SliverToBoxAdapter(
          //   child: Header(overview: overview),
          // ),
          SliverToBoxAdapter(
            child: Container(
              height: 10,
              color: const Color(0xFFF6F7FA),
            ),
          ),
          SliverToBoxAdapter(
            child: _TabSwitchBar(selectedTab: selectedTab),
          ),
          if (selectedTab == _Tab.swap) ...[
            SliverToBoxAdapter(
                child: Transform(
                    transform: Matrix4.identity()..scale(0.9),
                    child: SwapAssetHeader(
                      sortType: sortType,
                      sortName: sortName,
                      type: SwapAssetHeaderType.pool,
                    ))),
            SwapPairsSliverList(sortName: sortName, swapPairs: swapPairMetas),
          ] else if (selectedTab == _Tab.overview) ...[
            SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.l10n.website,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: context.colorScheme.thirdText),
                                ),
                                Text(
                                  info.website,
                                  style: const TextStyle(
                                    color: Color(0xFF000000),
                                  ),
                                )
                              ]),
                          const SizedBox(height: 8),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                      Text(
                                        context.l10n.totalSupply,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color:
                                                context.colorScheme.thirdText),
                                      ),
                                      Text(
                                        info.total.toFiat(),
                                        style: const TextStyle(
                                          color: Color(0xFF000000),
                                        ),
                                      )
                                    ])),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                      Text(
                                        context.l10n.marketCap,
                                        style: TextStyle(
                                            color:
                                                context.colorScheme.thirdText),
                                      ),
                                      Text(
                                        info.circulation.toFiat(),
                                        style: const TextStyle(
                                          color: Color(0xFF000000),
                                        ),
                                      )
                                    ])),
                              ]),
                          const SizedBox(height: 8),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                      Text(
                                        context.l10n.totalLiquidity,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color:
                                                context.colorScheme.thirdText),
                                      ),
                                      Text(
                                        overview.totalUSDValue.toFiat,
                                        style: const TextStyle(
                                          color: Color(0xFF000000),
                                        ),
                                      )
                                    ])),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                      Text(
                                        context.l10n.price,
                                        style: TextStyle(
                                            color:
                                                context.colorScheme.thirdText),
                                      ),
                                      Text(
                                        data.price.toFiat(),
                                        style: const TextStyle(
                                          color: Color(0xFF000000),
                                        ),
                                      )
                                    ])),
                              ]),
                          const SizedBox(height: 8),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                      Text(
                                        context.l10n.globalVol,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color:
                                                context.colorScheme.thirdText),
                                      ),
                                      Text(
                                        overview.volume24h.toFiat,
                                        style: const TextStyle(
                                          color: Color(0xFF000000),
                                        ),
                                      )
                                    ])),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                      Text(
                                        context.l10n.trades,
                                        style: TextStyle(
                                            color:
                                                context.colorScheme.thirdText),
                                      ),
                                      Text(
                                        overview.transactions.toString(),
                                        style: const TextStyle(
                                          color: Color(0xFF000000),
                                        ),
                                      )
                                    ])),
                              ]),
                          const SizedBox(height: 8),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                      Text(
                                        context.l10n.issueTime,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color:
                                                context.colorScheme.thirdText),
                                      ),
                                      Text(
                                        info.issue,
                                        style: const TextStyle(
                                          color: Color(0xFF000000),
                                        ),
                                      )
                                    ])),
                                const SizedBox(width: 10),
                                Expanded(child: Container()),
                              ]),
                          const SizedBox(height: 8),
                          Container(child: buildGrid()),
                        ])))
          ],
        ],
      ),
    );
  }
}

class _TabSwitchBar extends HookWidget implements PreferredSizeWidget {
  const _TabSwitchBar({
    Key? key,
    required this.selectedTab,
  }) : super(key: key);

  final _Tab selectedTab;

  @override
  Widget build(BuildContext context) {
    final controller = useTabController(
      initialLength: 2,
      initialIndex: selectedTab.index,
      keys: [selectedTab],
    );
    useEffect(() {
      void onTabChanged() {
        final params = <String, String>{};
        params[kQueryParameterTab] = _Tab.values[controller.index].name;
        context
            .replace(Uri(path: context.path).replace(queryParameters: params));
      }

      controller.addListener(onTabChanged);
      return () => controller.removeListener(onTabChanged);
    }, []);
    return SizedBox(
      height: 60,
      child: TabBar(
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        labelColor: context.colorScheme.primaryText,
        unselectedLabelColor: const Color(0xFFBCBEC3),
        tabs: [
          Tab(text: context.l10n.swap),
          Tab(text: context.l10n.overview),
        ],
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 3,
        indicator: BoxDecoration(
          color: context.colorScheme.accent,
          borderRadius: BorderRadius.circular(6),
        ),
        indicatorPadding: const EdgeInsets.only(bottom: 16, top: 41),
        controller: controller,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
