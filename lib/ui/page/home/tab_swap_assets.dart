import 'package:flutter/material.dart';

import './swap_asset_header.dart';
import '../../../util/extension/extension.dart';
import '../../../util/swap_asset.dart';
import '../../widget/swap_asset.dart';
import 'empty.dart';

class SwapAssetsSliverList extends StatelessWidget {
  const SwapAssetsSliverList({
    Key? key,
    required this.swapAssetList,
    required this.sortName,
  }) : super(key: key);

  final List<SwapAssetMeta> swapAssetList;
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
          return SwapAssetWidget(sortName: sortName, data: item);
        },
        childCount: swapAssetList.length,
      ),
    );
  }
}
