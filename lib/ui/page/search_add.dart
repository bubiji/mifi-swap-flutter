import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../models/m_swap_assetmeta_CartModel.dart';
import '../router/mixin_routes.dart';
import '../widget/add_swap_asset.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';
import '../widget/search_text_field_widget.dart';
import 'home/empty.dart';
import 'home/swap_asset_header.dart';

// the selected tab.
const kQueryParameterTab = 'tab';

enum _Tab {
  swapAssets,
  pool,
}

class Search_Add extends HookWidget {
  const Search_Add({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final sortParam =
    //     useQueryParameter(kQueryParameterSort, path: searchUri.path);

    final swapAssetCount = useState<int>(0);

    Future<void> loadSwapAssetList() async {
      final swapAssetList =
          await context.mixinDatabase.swapAssetDao.getAll().get();
      final model = context.read<SwapAssetListModel>();
      model.update(swapAssetList);
      swapAssetCount.value = swapAssetList.length;
    }

    useEffect(() {
      loadSwapAssetList();
      return () {};
    }, []);

    final sortNameParam =
        useQueryParameter(kQueryParameterSortName, path: searchUri.path);

    final tabParam =
        useQueryParameter(kQueryParameterTab, path: searchUri.path);
    final selectedTab = _Tab.values.byNameOrNull(tabParam) ?? _Tab.swapAssets;

    // final sortType = useMemoized(
    //     () =>
    //         SwapAssetSortType.values.byNameOrNull(sortParam) ?? SwapAssetSortType.none,
    //     [sortParam]);

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
    //获取资产列表
    final swapAssetList = useMemoized(
        () => swapAssetResults
            // .where((swapAsset) => !(swapAsset.symbol ?? '').contains('-'))
            .map((swapAsset) => getMySwapAssetMeta())
            .toList(),
        [swapAssetResults]);
    //print(swapAssetResults);
    // useMemoized(() {
    //   if (selectedTab != _Tab.swapAssets) {
    //     return;
    //   }
    //   swapAssetList.sortBy(sortName, sortType);
    // }, [swapAssetList, sortName, sortType, selectedTab]);
    //
    // final swapPairMetas = useMemoized(() => makeSwapPairMeta(swapPairResults, swapAssetResults),
    //     [swapPairResults, swapAssetResults]);
    //
    // useMemoized(() {
    //   if (selectedTab != _Tab.pool) {pe);
    //     // }, [swapPairMetas, sortName, sortType,
    //     return;
    //   }
    //   swapPairMetas.sortBy(sortName, sortTyselectedTab]);

    //搜索输入框
    final inputText = useState('');
    //print(inputText.value);

    const item = SwapAsset(
        id: 'a',
        logo: 'logo',
        name: 'btc',
        price: '123',
        symbol: '',
        extra: 'extra',
        chainId: 'chainId',
        chainLogo: 'chainLogo',
        chainName: 'chainName');
    const item2 = SwapAsset(
        id: 'a',
        logo: 'logo',
        name: 'eth',
        price: '123',
        symbol: '',
        extra: 'extra',
        chainId: 'chainId',
        chainLogo: 'chainLogo',
        chainName: 'chainName');
    final swapAssetitemList = <SwapAsset>[];
    swapAssetitemList.add(item2);
    swapAssetitemList.add(item);

    final searchSwapAssetList = useMemoized(
        () => swapAssetitemList.where((swapAsset) {
              final symbol = (swapAsset.name ?? '').trim().toUpperCase();
              final k = (inputText.value).toUpperCase();
              return symbol.contains(k);
            }).toList(),
        [inputText.value]);
    //  print('searchSwapAssetList');
    // print(searchSwapAssetList.toList());
    return Scaffold(
      appBar: MixinAppBar(
        leading: const MixinBackHomeButton(),
        title: SelectableText(
          context.l10n.AddAsset,
          style: TextStyle(
            color: context.colorScheme.primaryText,
            fontSize: 18,
          ),
          enableInteractiveSelection: false,
        ),
        backgroundColor: context.colorScheme.background,
      ),
      //backgroundColor: context.theme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
              child: SearchTextFieldWidget(
                  fontSize: 16,
                  controller: useTextEditingController(),
                  hintText: context.l10n.search,
                  onChanged: (e) => {inputText.value = e})),
          if (inputText.value != '') ...[
            AddSwapAssetsSliverList(
                sortName: sortName, swapAssetList: searchSwapAssetList),
          ],
          //// cart
          // _MyAppBar(),
          // const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (swapAssetCount.value > 0)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _MyListItem(index),
                childCount: swapAssetCount.value,
              ),
            ),
          // SliverList(
          //   delegate: SliverChildBuilderDelegate(
          //       (context, index) => _MyListItem(index)),
          //),
        ],
      ),
    );
  }
}

class AddSwapAssetsSliverList extends StatelessWidget {
  const AddSwapAssetsSliverList({
    Key? key,
    required this.swapAssetList,
    required this.sortName,
  }) : super(key: key);

  final List<SwapAsset> swapAssetList;
  final SwapAssetSortName sortName;

  @override
  Widget build(BuildContext context) {
    if (swapAssetList.isEmpty) {
      return SliverFillRemaining(
        child: EmptyLayout(content: context.l10n.noAsset),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final item = swapAssetList[index];
          return AddSwapAssetWidget(data: item);
        },
        childCount: swapAssetList.length,
      ),
    );
    // return SliverList(
    //      delegate: SliverChildBuilderDelegate(
    //         // (context, index) => _MyListItem(index)),
    //    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.item});
  final SwapAsset item;

  @override
  Widget build(BuildContext context) {
    // The context.select() method will let you listen to changes to
    // a *part* of a model. You define a function that "selects" (i.e. returns)
    // the part you're interested in, and the provider package will not rebuild
    // this widget unless that particular part of the model changes.
    //
    // This can lead to significant performance improvements.
    final isInCart = context.select<MySwapAsset_CartModel, bool>(
      // Here, we are only interested whether [item] is inside the cart.
      (cart) => cart.items.contains(item),
    );

    return TextButton(
      onPressed: isInCart
          ? null
          : () {
              // If the item is not in cart, we let the user add it.
              // We are using context.read() here because the callback
              // is executed whenever the user taps the button. In other
              // words, it is executed outside the build method.
              final cart = context.read<MySwapAsset_CartModel>();
              cart.add(item);
            },
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.pressed)) {
            return Theme.of(context).primaryColor;
          }
          return null; // Defer to the widget's default.
        }),
      ),
      child: isInCart
          ? const Icon(Icons.check, semanticLabel: 'ADDED')
          : const Text('ADD'),
    );
  }
}

class _MyListItem extends StatelessWidget {
  const _MyListItem(this.index);
  final int index;
  @override
  Widget build(BuildContext context) {
    final item = context.select<SwapAssetListModel, SwapAsset>(
      // Here, we are only interested in the item at [index]. We don't care
      // about any other change.
      (catalog) => catalog.getByPosition(index),
    );
    final textTheme = Theme.of(context).textTheme.titleLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LimitedBox(
        maxHeight: 48,
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                  //color: item.color,
                  ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(item.name, style: textTheme),
            ),
            const SizedBox(width: 24),
            _AddButton(item: item),
          ],
        ),
      ),
    );
  }
}
//购物车及返回按钮
// class _MyAppBar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SliverAppBar(
//       title: Text('Catalog', style: Theme.of(context).textTheme.displayLarge),
//       floating: true,
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.shopping_cart),
//           onPressed: () => Navigator.pushNamed(context, '/cart'),
//         ),
//       ],
//     );
//   }
// }
