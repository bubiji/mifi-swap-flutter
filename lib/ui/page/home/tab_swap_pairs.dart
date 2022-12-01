import 'package:flutter/material.dart';

import './swap_asset_header.dart';
import '../../../util/extension/extension.dart';
import '../../../util/swap_pair.dart';
import '../../widget/swap_pair.dart';
import 'empty.dart';

class SwapPairsSliverList extends StatelessWidget {
  const SwapPairsSliverList({
    Key? key,
    required this.swapPairs,
    required this.sortName,
  }) : super(key: key);

  final List<SwapPairMeta> swapPairs;
  final SwapAssetSortName sortName;

  @override
  Widget build(BuildContext context) {
    if (swapPairs.isEmpty) {
      return SliverFillRemaining(
        child: EmptyLayout(content: context.l10n.noAsset),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final item = swapPairs[index];
          return SwapPairWidget(sortName: sortName, data: item);
        },
        childCount: swapPairs.length,
      ),
    );
  }
}
