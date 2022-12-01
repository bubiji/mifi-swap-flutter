import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/swap_asset.dart';
import '../../util/swap_pair.dart';
import '../router/mixin_routes.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';
import '../widget/search_text_field_widget.dart';
import 'home/swap_asset_header.dart';
import 'home/tab_swap_assets.dart';
import 'home/tab_swap_pairs.dart';

// the selected tab.
const kQueryParameterTab = 'tab';

enum _Tab {
  swapAssets,
  pool,
}

class Search extends HookWidget {
  const Search({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortParam =
        useQueryParameter(kQueryParameterSort, path: searchUri.path);

    final sortNameParam =
        useQueryParameter(kQueryParameterSortName, path: searchUri.path);

    final tabParam =
        useQueryParameter(kQueryParameterTab, path: searchUri.path);
    final selectedTab = _Tab.values.byNameOrNull(tabParam) ?? _Tab.swapAssets;

    final sortType = useMemoized(
        () =>
            SwapAssetSortType.values.byNameOrNull(sortParam) ??
            SwapAssetSortType.none,
        [sortParam]);

    final sortName = useMemoized(() {
      final name = selectedTab == _Tab.swapAssets
          ? SwapAssetSortName.price
          : SwapAssetSortName.liquidity;
      return SwapAssetSortName.values.byNameOrNull(sortNameParam) ?? name;
    }, [sortNameParam, selectedTab]);

    final swapAssetResults = useMemoizedStream(
      () => context.appServices.mixinDatabase.swapAssetDao.getAll().watch(),
      initialData: <SwapAsset>[],
    ).requireData;

    final swapPairResults = useMemoizedStream(
      () => context.appServices.mixinDatabase.swapPairDao.getAll().watch(),
      initialData: <SwapPair>[],
    ).requireData;

    final swapAssetList = useMemoized(
        () => swapAssetResults
            // .where((swapAsset) => !(swapAsset.symbol ?? '').contains('-'))
            .map((swapAsset) =>
                getSwapAssetSwapPairsMeta(swapAsset, swapPairResults))
            .toList(),
        [swapAssetResults, swapPairResults]);

    useMemoized(() {
      if (selectedTab != _Tab.swapAssets) {
        return;
      }
      swapAssetList.sortBy(sortName, sortType);
    }, [swapAssetList, sortName, sortType, selectedTab]);

    final swapPairMetas = useMemoized(
        () => makeSwapPairMeta(swapPairResults, swapAssetResults),
        [swapPairResults, swapAssetResults]);

    useMemoized(() {
      if (selectedTab != _Tab.pool) {
        return;
      }
      swapPairMetas.sortBy(sortName, sortType);
    }, [swapPairMetas, sortName, sortType, selectedTab]);

    final inputText = useState('');
    final searchSwapAssetList = useMemoized(
        () => swapAssetList.where((swapAsset) {
              final symbol =
                  (swapAsset.swapAsset.symbol ?? '').trim().toUpperCase();
              final k = (inputText.value).toUpperCase();
              return symbol.contains(k);
            }).toList(),
        [inputText.value]);

    final searchSwapPairMetas = useMemoized(
        () => swapPairMetas.where((swapPair) {
              final symbol = (swapPair.symbol).trim().toUpperCase();
              final k = (inputText.value).toUpperCase();
              return symbol.contains(k);
            }).toList(),
        [inputText.value]);

    return Scaffold(
      appBar: MixinAppBar(
        leading: const MixinBackHomeButton(),
        title: SelectableText(
          context.l10n.search,
          style: TextStyle(
            color: context.colorScheme.primaryText,
            fontSize: 18,
          ),
          enableInteractiveSelection: false,
        ),
        backgroundColor: context.colorScheme.background,
      ),
      backgroundColor: context.theme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
              child: SearchTextFieldWidget(
                  fontSize: 16,
                  controller: useTextEditingController(),
                  hintText: context.l10n.search,
                  onChanged: (e) => {inputText.value = e})),
          if (inputText.value != '') ...[
            SliverToBoxAdapter(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  SizedBox(
                      width: 200,
                      child: _TabSwitchBar(selectedTab: selectedTab)),
                ])),
            if (selectedTab == _Tab.swapAssets) ...[
              SliverToBoxAdapter(
                  child: Transform(
                      transform: Matrix4.identity()..scale(0.9),
                      child: SwapAssetHeader(
                        sortType: sortType,
                        sortName: sortName,
                        type: SwapAssetHeaderType.swapAssets,
                      ))),
              SwapAssetsSliverList(
                  sortName: sortName, swapAssetList: searchSwapAssetList),
            ] else if (selectedTab == _Tab.pool) ...[
              SliverToBoxAdapter(
                  child: Transform(
                      transform: Matrix4.identity()..scale(0.9),
                      child: SwapAssetHeader(
                        sortType: sortType,
                        sortName: sortName,
                        type: SwapAssetHeaderType.pool,
                      ))),
              SwapPairsSliverList(
                  sortName: sortName, swapPairs: searchSwapPairMetas),
            ],
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
        context.replace(searchUri.replace(queryParameters: params));
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
          Tab(text: context.l10n.assets),
          Tab(text: context.l10n.pools),
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
