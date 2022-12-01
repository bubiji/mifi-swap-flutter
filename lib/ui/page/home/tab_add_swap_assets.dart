// import 'package:flutter/material.dart';
//
// import '../../models/m_swap_assetmeta_CartModel.dart';
// import './swap_asset_header.dart';
// import '../../../util/extension/extension.dart';
// import '../../widget/add_swap_asset.dart';
// import 'empty.dart';
//
// class AddSwapAssetsSliverList extends StatelessWidget {
//   const AddSwapAssetsSliverList({
//     Key? key,
//     required this.swapAssetList,
//     required this.sortName,
//   }) : super(key: key);
//
//   final List<MySwapAssetMeta> swapAssetList;
//   final SwapAssetSortName sortName;
//
//   @override
//   Widget build(BuildContext context) {
//     if (swapAssetList.isEmpty) {
//       return SliverFillRemaining(
//         child: EmptyLayout(content: context.l10n.noAsset),
//       );
//     }
//     return SliverList(
//       delegate: SliverChildBuilderDelegate(
//         (BuildContext context, int index) {
//           final item = swapAssetList[index];
//           return AddSwapAssetWidget(sortName: sortName, data: item);
//         },
//         childCount: swapAssetList.length,
//       ),
//     );
//   }
// }
