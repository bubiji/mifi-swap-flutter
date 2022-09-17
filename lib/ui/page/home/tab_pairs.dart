import 'package:flutter/material.dart';

import './asset_header.dart';
import '../../../util/extension/extension.dart';
import '../../../util/pair.dart';
import '../../widget/pair.dart';
import 'empty.dart';

class PairsSliverList extends StatelessWidget {
  const PairsSliverList({
    Key? key,
    required this.pairs,
    required this.sortName,
  }) : super(key: key);

  final List<PairMeta> pairs;
  final AssetSortName sortName;

  @override
  Widget build(BuildContext context) {
    if (pairs.isEmpty) {
      return SliverFillRemaining(
        child: EmptyLayout(content: context.l10n.noAsset),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final item = pairs[index];
          return PairWidget(sortName: sortName, data: item);
        },
        childCount: pairs.length,
      ),
    );
  }
}
