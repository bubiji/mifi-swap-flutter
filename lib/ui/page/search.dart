import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../db/mixin_database.dart';
import '../../util/asset.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/pair.dart';
import '../router/mixin_routes.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';
import '../widget/search_text_field_widget.dart';
import 'home/asset_header.dart';
import 'home/tab_assets.dart';
import 'home/tab_pairs.dart';

// the selected tab.
const kQueryParameterTab = 'tab';

enum _Tab {
  assets,
  pool,
}

class Search extends HookWidget {
  const Search({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // assert(context.appServices.databaseInitialized);

    useMemoizedFuture(() => context.appServices.updatePairs());
    final sortParam =
        useQueryParameter(kQueryParameterSort, path: searchUri.path);

    final sortNameParam =
        useQueryParameter(kQueryParameterSortName, path: searchUri.path);

    final tabParam =
        useQueryParameter(kQueryParameterTab, path: searchUri.path);
    final selectedTab = _Tab.values.byNameOrNull(tabParam) ?? _Tab.assets;

    final sortType = useMemoized(
        () =>
            AssetSortType.values.byNameOrNull(sortParam) ?? AssetSortType.none,
        [sortParam]);

    final sortName = useMemoized(() {
      final name = selectedTab == _Tab.assets
          ? AssetSortName.price
          : AssetSortName.liquidity;
      return AssetSortName.values.byNameOrNull(sortNameParam) ?? name;
    }, [sortNameParam, selectedTab]);

    final assetResults = useMemoizedStream(
      () => context.appServices.mixinDatabase.assetDao.getAll().watch(),
      initialData: <Asset>[],
    ).requireData;

    final pairResults = useMemoizedStream(
      () => context.appServices.mixinDatabase.pairDao.getAll().watch(),
      initialData: <Pair>[],
    ).requireData;

    final assetList = useMemoized(
        () => assetResults
            // .where((asset) => !(asset.symbol ?? '').contains('-'))
            .map((asset) => getAssetMeta(asset, pairResults))
            .toList(),
        [assetResults, pairResults]);

    useMemoized(() {
      if (selectedTab != _Tab.assets) {
        return;
      }
      assetList.sortBy(sortName, sortType);
    }, [assetList, sortName, sortType, selectedTab]);

    final pairMetas = useMemoized(() => makePairMeta(pairResults, assetResults),
        [pairResults, assetResults]);

    useMemoized(() {
      if (selectedTab != _Tab.pool) {
        return;
      }
      pairMetas.sortBy(sortName, sortType);
    }, [pairMetas, sortName, sortType, selectedTab]);

    final inputText = useState('');
    final searchAssetList = useMemoized(
        () => assetList.where((asset) {
              final symbol = (asset.asset.symbol ?? '').trim().toUpperCase();
              final k = (inputText.value).toUpperCase();
              return symbol.contains(k);
            }).toList(),
        [inputText.value]);

    final searchPairMetas = useMemoized(
        () => pairMetas.where((pair) {
              final symbol = (pair.symbol).trim().toUpperCase();
              final k = (inputText.value).toUpperCase();
              return symbol.contains(k);
            }).toList(),
        [inputText.value]);

    return Scaffold(
      appBar: MixinAppBar(
        leading: const MixinBackButton2(),
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
            if (selectedTab == _Tab.assets) ...[
              SliverToBoxAdapter(
                  child: Transform(
                      transform: Matrix4.identity()..scale(0.9),
                      child: AssetHeader(
                        sortType: sortType,
                        sortName: sortName,
                        type: AssetHeaderType.assets,
                      ))),
              AssetsSliverList(sortName: sortName, assetList: searchAssetList),
            ] else if (selectedTab == _Tab.pool) ...[
              SliverToBoxAdapter(
                  child: Transform(
                      transform: Matrix4.identity()..scale(0.9),
                      child: AssetHeader(
                        sortType: sortType,
                        sortName: sortName,
                        type: AssetHeaderType.pool,
                      ))),
              PairsSliverList(sortName: sortName, pairs: searchPairMetas),
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
      void _onTabChanged() {
        final params = <String, String>{};
        params[kQueryParameterTab] = _Tab.values[controller.index].name;
        context.replace(searchUri.replace(queryParameters: params));
      }

      controller.addListener(_onTabChanged);
      return () => controller.removeListener(_onTabChanged);
    });
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
        tabs: const [
          Tab(text: 'Assets'),
          Tab(text: 'Pool'),
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
