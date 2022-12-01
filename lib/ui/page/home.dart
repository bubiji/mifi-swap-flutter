import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/r.dart';
import '../../util/swap_asset.dart';
import '../../util/swap_pair.dart';
import '../models/m_swap_assetmeta_CartModel.dart';
import '../router/mixin_routes.dart';
import '../widget/account.dart';
import 'home/swap_asset_header.dart';
import 'home/tab_activity.dart';
import 'home/wallent_header.dart';

// the selected tab.
const kQueryParameterTab = 'tab';

enum _Tab {
  swapAssets,
  activity,
}

class Home extends HookWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final swapAssetCount = useState<int>(0);

    Future<void> loadSwapAssetList() async {
      final swapAssetList =
          await context.mixinDatabase.swapAssetDao.getAll().get();
      final model = context.read<SwapAssetListModel>();
      model.update(swapAssetList);
      swapAssetCount.value = swapAssetList.length;
    }

    useMemoizedFuture(() async {
      await context.appServices.updateSwapPairsAndSwapAssets();
      await loadSwapAssetList();
    });

    useEffect(() {
      loadSwapAssetList();
      return () {};
    }, []);

    final sortParam =
        useQueryParameter(kQueryParameterSort, path: homeUri.path);

    final sortNameParam =
        useQueryParameter(kQueryParameterSortName, path: homeUri.path);

    final tabParam = useQueryParameter(kQueryParameterTab, path: homeUri.path);
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
      if (selectedTab != _Tab.activity) {
        return;
      }
      swapPairMetas.sortBy(sortName, sortType);
    }, [swapPairMetas, sortName, sortType, selectedTab]);

    final overview = useMemoized(() {
      final overview = SwapPairOverview();
      swapPairResults.forEach(overview.plus);
      return overview;
    }, [swapPairResults]);

    return Scaffold(
      backgroundColor: context.theme.background,
      appBar: const TopAppBar(),
      body: Container(
        child: Column(children: [
          Wallent_Header(overview: overview),
          Container(
            height: 10,
            color: const Color(0xFFF6F7FA),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SizedBox(
                width: 300, child: _TabSwitchBar(selectedTab: selectedTab)),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: InkResponse(
                radius: 16,
                onTap: () => context.push(searchUri.toString()),
                child: SvgPicture.asset(
                  R.resourcesPlusSvg,
                  height: 16,
                  width: 16,
                  color: context.colorScheme.primaryText,
                ),
              ),
            )
          ]),
          if (selectedTab == _Tab.swapAssets) ...[
            // SliverToBoxAdapter(
            //     child: Transform(
            //         transform: Matrix4.identity()..scale(0.9),
            //         child: SwapAssetHeader(
            //           sortType: sortType,
            //           sortName: sortName,
            //           type: SwapAssetHeaderType.swapAssets,
            //         ))),
            //SwapAssetsSliverList(sortName: sortName, swapAssetList: swapAssetList),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _CartList(),
              ),
            ),
            const Divider(height: 4, color: Colors.black),
            //_CartTotal()
          ] else if (selectedTab == _Tab.activity) ...[
            // SliverToBoxAdapter(
            //     child: Transform(
            //         transform: Matrix4.identity()..scale(0.9),
            //         child: SwapAssetHeader(
            //           sortType: sortType,
            //           sortName: sortName,
            //           type: SwapAssetHeaderType.pool,
            //         ))),
            AvtivitySliverList(sortName: sortName, swapPairs: swapPairMetas),
          ],
        ]
            // _CartTotal()
            ),
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
        context.replace(homeUri.replace(queryParameters: params));
      }

      controller.addListener(onTabChanged);
      return () => controller.removeListener(onTabChanged);
    }, []);
    return SizedBox(
      height: 60,
      child: TabBar(
        labelStyle: const TextStyle(
          fontSize: 16,
          // fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          //fontWeight: FontWeight.w400,
        ),
        labelColor: context.colorScheme.primaryText,
        unselectedLabelColor: const Color(0xFFBCBEC3),
        tabs: [
          Tab(text: context.l10n.assets),
          Tab(text: context.l10n.myActivity),
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

class _CartList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemNameStyle = Theme.of(context).textTheme.titleLarge;
    // This gets the current state of CartModel and also tells Flutter
    // to rebuild this widget when CartModel notifies listeners (in other words,
    // when it changes).
    final cart = context.watch<MySwapAsset_CartModel>();

    return ListView.builder(
      itemCount: cart.items.length,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.done),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () {
            cart.remove(cart.items[index]);
          },
        ),
        title: Text(
          cart.items[index].name,
          style: itemNameStyle,
        ),
      ),
    );
  }
}
// 总价计算
// class _CartTotal extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var hugeStyle =
//         Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 48);
//
//     return SizedBox(
//       height: 200,
//       child: Center(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Another way to listen to a model's change is to include
//             // the Consumer widget. This widget will automatically listen
//             // to CartModel and rerun its builder on every change.
//             //
//             // The important thing is that it will not rebuild
//             // the rest of the widgets in this build method.
//             Consumer<CartModel>(
//                 builder: (context, cart, child) =>
//                     Text('\$${cart.totalPrice}', style: hugeStyle)),
//             const SizedBox(width: 24),
//             TextButton(
//               onPressed: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Buying not supported yet.')));
//               },
//               style: TextButton.styleFrom(foregroundColor: Colors.white),
//               child: const Text('BUY'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
