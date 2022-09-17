import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../util/extension/extension.dart';
import '../../util/pair.dart';
import '../page/home/asset_header.dart';
import '../router/mixin_routes.dart';
import 'symbol.dart';

class PairWidget extends StatelessWidget {
  const PairWidget({
    Key? key,
    required this.data,
    required this.sortName,
  }) : super(key: key);

  final PairMeta data;
  final AssetSortName sortName;

  @override
  Widget build(BuildContext context) {
    void onTap() {
      context.push(assetDetailPath.toUri({'id': data.pair.baseAssetId}));
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Transform.translate(
                offset: const Offset(27, 0),
                child: SymbolIconWithBorder(
                  symbolUrl: data.quoteAsset.logo,
                  chainUrl: data.quoteAsset.chainLogo,
                  size: 30,
                  chainSize: 10.5,
                  chainBorder: BorderSide(
                    color: context.colorScheme.background,
                    width: 1.125,
                  ),
                )),
            Transform.translate(
                offset: const Offset(-30, 0),
                child: SymbolIconWithBorder(
                  symbolUrl: data.baseAsset.logo,
                  chainUrl: data.baseAsset.chainLogo,
                  size: 30,
                  chainSize: 10.5,
                  chainBorder: BorderSide(
                    color: context.colorScheme.background,
                    width: 1.125,
                  ),
                  symbolBorder: BorderSide(
                    color: context.colorScheme.background,
                    width: 2,
                  ),
                )),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: LayoutBuilder(
                          builder: (context, constraints) =>
                              SingleLineEllipsisText(
                            data.symbol.overflow,
                            constraints: constraints,
                            onTap: onTap,
                            style: TextStyle(
                              color: context.colorScheme.primaryText,
                              fontSize: 16,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    data.priceText,
                    style: TextStyle(
                      color: context.colorScheme.thirdText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            PairPrice(sortName: sortName, data: data),
          ],
        ),
      ),
    );
  }
}

class PairPrice extends StatelessWidget {
  const PairPrice({
    Key? key,
    required this.data,
    required this.sortName,
  }) : super(key: key);

  final PairMeta data;
  final AssetSortName sortName;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (AssetSortName.turnOver == sortName)
            Percentage(
              change: data.turnOver,
            )
          else
            Text(
              AssetSortName.volume24h == sortName
                  ? data.pair.volume24h.toFiat()
                  : data.volume.toFiat,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: context.colorScheme.thirdText,
                fontSize: 14,
              ),
            ),
        ],
      );
}

/// A text wrapper for ellipsis, because text ellipsis do not work
/// on Android Webview.
/// Remove when https://github.com/flutter/flutter/issues/86776 has been fixed.
class SingleLineEllipsisText extends HookWidget {
  const SingleLineEllipsisText(
    this.text, {
    Key? key,
    this.style,
    required this.constraints,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final TextStyle? style;
  final BoxConstraints constraints;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);

    final endIndex = useMemoized(() {
      final maxWidth = constraints.maxWidth;
      final textSpan = TextSpan(
        text: text,
        style: style,
      );

      final textPainter = TextPainter(
        text: TextSpan(text: '...', style: style),
        textDirection: direction,
        maxLines: 1,
      )..layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
      final overflowTextSpanSize = textPainter.size;

      textPainter
        ..text = textSpan
        ..layout(
            minWidth: math.max(
              constraints.minWidth - overflowTextSpanSize.width,
              0,
            ),
            maxWidth: math.max(
              maxWidth - overflowTextSpanSize.width,
              0,
            ));

      // TextPainter.didExceedMaxLines did not work on Web
      // https://github.com/flutter/flutter/issues/65940
      // So we use a fixed value to avoid overflow.
      final pos = textPainter.getPositionForOffset(Offset(
        maxWidth - 32,
        0,
      ));
      return pos.offset;
    }, [text, style, direction, constraints]);

    final resultText = useMemoized(
      () {
        if (endIndex == -1 || endIndex == text.length) {
          return text;
        }
        return '${text.substring(0, endIndex)}...';
      },
      [text, endIndex],
    );

    return SelectableText(
      resultText,
      style: style,
      maxLines: 1,
      enableInteractiveSelection: false,
      onTap: onTap,
    );
  }
}
