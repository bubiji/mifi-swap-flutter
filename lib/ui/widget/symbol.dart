import 'package:cached_network_image/cached_network_image.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/r.dart';
import '../../util/extension/extension.dart';

class SymbolIconWithBorder extends StatelessWidget {
  const SymbolIconWithBorder({
    Key? key,
    required this.symbolUrl,
    this.chainUrl,
    required this.size,
    required this.chainSize,
    this.chainBorder = const BorderSide(color: Colors.white, width: 1),
    this.symbolBorder = BorderSide.none,
  }) : super(key: key);

  final String symbolUrl;
  final String? chainUrl;
  final double size;
  final double chainSize;

  final BorderSide chainBorder;

  final BorderSide symbolBorder;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size + symbolBorder.width,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.symmetric(
                    vertical: symbolBorder,
                    horizontal: symbolBorder,
                  ),
                ),
                child: CachedNetworkImage(
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  imageUrl: symbolUrl,
                ),
              ),
            ),
            if (chainUrl == null)
              Container()
            else
              Positioned(
                left: 0,
                bottom: 0,
                child: Transform.translate(
                  offset: Offset(
                    symbolBorder.width - chainBorder.width,
                    chainBorder.width - symbolBorder.width,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.symmetric(
                        vertical: chainBorder,
                        horizontal: chainBorder,
                      ),
                    ),
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      imageUrl: chainUrl ?? '',
                      width: chainSize,
                      height: chainSize,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

class PercentageChange extends StatelessWidget {
  const PercentageChange({
    Key? key,
    required this.changeUsd,
  }) : super(key: key);

  final String changeUsd;

  @override
  Widget build(BuildContext context) {
    final decimal = Decimal.tryParse(changeUsd) ?? Decimal.zero;
    final negative = decimal < Decimal.zero;
    final change = (decimal.abs() * Decimal.fromInt(100))
        .toDouble()
        .currencyFormatWithoutSymbol;

    final text = Text(
      '$change%',
      textAlign: TextAlign.right,
      style: TextStyle(
        color: negative ? context.colorScheme.red : context.colorScheme.green,
        fontSize: 14,
      ),
    );
    if (decimal == Decimal.zero) {
      return text;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          negative ? R.resourcesDownRedSvg : R.resourcesUpGreenSvg,
          width: 6,
          height: 11,
          allowDrawingOutsideViewBox: true,
        ),
        const SizedBox(width: 4),
        text,
      ],
    );
  }
}

class Percentage extends StatelessWidget {
  const Percentage({
    Key? key,
    required this.change,
  }) : super(key: key);

  final Decimal change;

  @override
  Widget build(BuildContext context) {
    final change = (this.change.abs() * Decimal.fromInt(100))
        .toDouble()
        .currencyFormatWithoutSymbol;

    return Text(
      '$change%',
      textAlign: TextAlign.right,
      style: TextStyle(
        color: context.colorScheme.thirdText,
        fontSize: 14,
      ),
    );
  }
}
