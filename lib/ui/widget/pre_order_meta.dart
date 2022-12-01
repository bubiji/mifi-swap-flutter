import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../util/extension/extension.dart';
import '../../util/r.dart';
import '../../util/swap_pair.dart';

class PreOrderMetaWidget extends HookWidget {
  const PreOrderMetaWidget({
    required this.preOrderMeta,
    required this.preOrderMeta10,
    required this.inputSymbol,
    required this.outputSymbol,
    required this.splitCount,
    Key? key,
  }) : super(key: key);
  final PreOrderMeta preOrderMeta;
  final PreOrderMeta preOrderMeta10;
  final String inputSymbol;
  final String outputSymbol;
  final int splitCount;
  // final double? size = 18;

  @override
  Widget build(BuildContext context) {
    const textStyleblack = TextStyle(color: Colors.black, fontSize: 15);
    final showReverse = useState<bool>(false);
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsetsDirectional.all(10),
        child: Column(
          children: [
            //section 1

            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.price,
                  style: textStyleblack,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                        showReverse.value
                            ? preOrderMeta.reversePriceText
                            : preOrderMeta.priceText,
                        style: textStyleblack),
                    Container(width: 10),
                    InkResponse(
                      radius: 14,
                      child: SvgPicture.asset(
                        R.resourcesSwapacrossSvg,
                        height: 14,
                        width: 14,
                        color: context.colorScheme.thirdText,
                      ),
                      onTap: () {
                        showReverse.value = !showReverse.value;
                      },
                    ),
                  ],
                )
              ],
            ),
            Container(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.spiltoutcome,
                  style: textStyleblack,
                ),
                Text(
                  //'${preOrderMeta10.minReceived} $outputSymbol'
                  '${(preOrderMeta10.minReceived - preOrderMeta.minReceived).toStringAsFixed(8)} $outputSymbol'
                      .overflow,
                  style: const TextStyle(color: Colors.orange, fontSize: 15),
                ),
              ],
            ),
            Container(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.split,
                  style: textStyleblack,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      splitCount.toString(),
                      style: textStyleblack,
                    ),
                  ],
                )
              ],
            ),

            Container(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
