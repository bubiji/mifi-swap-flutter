import 'package:flutter/material.dart';

import './asset_header.dart';
import '../../../util/asset.dart';
import '../../../util/extension/extension.dart';
import '../../widget/asset.dart';
import 'empty.dart';

class AssetsSliverList extends StatelessWidget {
  const AssetsSliverList({
    Key? key,
    required this.assetList,
    required this.sortName,
  }) : super(key: key);

  final List<AssetMeta> assetList;
  final AssetSortName sortName;

  @override
  Widget build(BuildContext context) {
    if (assetList.isEmpty) {
      return SliverFillRemaining(
        child: EmptyLayout(content: context.l10n.noAsset),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final item = assetList[index];
          return AssetWidget(sortName: sortName, data: item);
        },
        childCount: assetList.length,
      ),
    );
  }
}
