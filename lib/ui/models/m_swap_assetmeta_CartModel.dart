import 'package:flutter/cupertino.dart';

import '../../db/mixin_database.dart';

class MySwapAsset_CartModel extends ChangeNotifier {
  /// The private field backing [catalog].
  late SwapAssetListModel _catalog;

  /// Internal, private state of the cart. Stores the ids of each item.
  final List<int> _itemIds = [];

  /// The current catalog. Used to construct items from numeric ids.
  SwapAssetListModel get catalog => _catalog;

  set catalog(SwapAssetListModel newCatalog) {
    _catalog = newCatalog;
    // Notify listeners, in case the new catalog provides information
    // different from the previous one. For example, availability of an item
    // might have changed.
    notifyListeners();
  }

  /// List of items in the cart.
  List<SwapAsset> get items =>
      _itemIds.map((id) => _catalog.getById(id)).toList();

  /// The current total price of all items.
  // int get totalPrice =>
  //     items.fold(0, (total, current) => total + current.price);

  /// Adds [item] to cart. This is the only way to modify the cart from outside.
  void add(SwapAsset item) {
    _itemIds.add(_catalog.swapAssetList.indexOf(item));

    // This line tells [Model] that it should rebuild the widgets that
    // depend on it.
    notifyListeners();
  }

  void remove(SwapAsset item) {
    _itemIds.remove(_catalog.swapAssetList.indexOf(item));

    // Don't forget to tell dependent widgets to rebuild _every time_
    // you change the model.
    notifyListeners();
  }
}

// SwapAssetMeta getSwapAssetSwapPairsMeta(
//   SwapAsset swapAsset,
//   List<SwapPair> swapPairs,
// ) =>
//     SwapAssetMeta(
//         swapAsset,
//         swapPairs
//             .where((swapPair) =>
//                 swapAsset.id == swapPair.baseAssetId || swapAsset.id == swapPair.quoteAssetId)
//             .toList());

//class CatalogModel {
class SwapAssetListModel {
  SwapAssetListModel();

  List<SwapAsset> swapAssetList = [];

  void update(List<SwapAsset> swapAssetList) {
    this.swapAssetList = [...swapAssetList];
  }

  /// Get item by [id].
  SwapAsset getById(int id) {
    if (swapAssetList.isEmpty) {
      return SwapAsset(
        id: 'a',
        logo: 'logo',
        name: 'btc$id',
        price: '123',
        symbol: '',
        extra: 'extra',
        chainId: 'chainId',
        chainLogo: 'chainLogo',
        chainName: 'chainName',
      );
    }
    return swapAssetList[id % swapAssetList.length];
  }

  /// Get item by its position in the catalog.
  SwapAsset getByPosition(int position) {
    // In this simplified case, an item's position in the catalog
    // is also its id.
    return getById(position);
  }
}
//

MySwapAsset_CartModel getMySwapAssetMeta() => MySwapAsset_CartModel();

// MySwapAsset_CartModel getSwapAssetMeta(
//     SwapAsset swapAsset,
//     List<SwapPair> swapPairs,
//     ) =>
//     MySwapAsset_CartModel(
//         swapAsset,
//         swapPairs
//             .where((swapPair) =>
//         swapAsset.id == swapPair.baseAssetId || swapAsset.id == swapPair.quoteAssetId)
//             .toList());
