part of '../extension.dart';

extension CurrencyExtension on dynamic {
  String get currencyFormat =>
      currentCurrencyNumberFormat.format(num.tryParse('$this'));

  String get currencyFormatWithoutSymbol =>
      currencyFormat.replaceAll(currentCurrencyNumberFormat.currencySymbol, '');

  String get currencyFormatCoin => NumberFormat().format(num.tryParse('$this'));

  NumberFormat get currentCurrencyNumberFormat =>
      NumberFormat.simpleCurrency(name: auth?.account.fiatCurrency);
}

extension StringCurrencyExtension on String {
  bool get isZero => (double.tryParse(this) ?? 0.0) == 0;

  Decimal get asDecimal => Decimal.tryParse(this) ?? Decimal.zero;

  String numberFormat() {
    if (isEmpty) return this;
    try {
      return NumberFormat(asDecimal.toString().getPattern(count: 32))
          .format(DecimalIntl(asDecimal));
    } catch (error) {
      return this;
    }
  }

  String toFiat() {
    if (isEmpty) return this;
    try {
      return asDecimal.toFiat;
    } catch (error) {
      return this;
    }
  }

  String getPattern({int count = 8}) {
    if (isEmpty) return '';

    final index = indexOf('.');
    if (index == -1) return ',###';
    if (index >= count) return ',###';

    final int bit;
    if (index == 1 && this[0] == '0') {
      bit = count + 1;
    } else if (index == 2 && this[0] == '-' && this[1] == '0') {
      bit = count + 2;
    } else {
      bit = count;
    }

    final sb = StringBuffer(',###.');

    // NumberFormat#_formatFixed power variable's type is [int],
    // and the maxValue of int is 9.223372e+18
    // So it only supports up to the 18th decimal place.
    final decimalPartLength = math.min(18, bit - index);

    for (var i = 0; i < decimalPartLength; i++) {
      sb.write('#');
    }
    return sb.toString();
  }
}

extension DoubleCurrencyExtension on num {
  Decimal get asDecimal => Decimal.parse('$this');
}

extension PriceFormat on Decimal {
  String get priceFormat {
    if (this > Decimal.one || this <= Decimal.zero) {
      return currencyFormat;
    }
    return NumberFormat.simpleCurrency(
            name: auth?.account.fiatCurrency, decimalDigits: 8)
        .format(num.tryParse('$this'));
  }

  String get toFiatZh {
    var fait =
        (this / Decimal.parse('10000')).toDecimal(scaleOnInfinitePrecision: 2);
    if (fait > Decimal.one) {
      return '\$${fait.toStringAsFixed(2)}万';
    }
    fait = (this / Decimal.one).toDecimal(scaleOnInfinitePrecision: 2);
    return '\$${fait.toStringAsFixed(2)}';
  }

  String get toFiatEn {
    var fait = (this / Decimal.parse('1000000'))
        .toDecimal(scaleOnInfinitePrecision: 2);
    if (fait > Decimal.one) {
      return '\$${fait.toStringAsFixed(2)}M';
    }
    fait =
        (this / Decimal.parse('1000')).toDecimal(scaleOnInfinitePrecision: 2);
    if (fait > Decimal.one) {
      return '\$${fait.toStringAsFixed(2)}K';
    }
    fait = (this / Decimal.one).toDecimal(scaleOnInfinitePrecision: 2);
    return '\$${fait.toStringAsFixed(2)}';
  }

  String get toFiat {
    if (Intl.defaultLocale == 'en') {
      return toFiatEn;
    } else {
      return toFiatZh;
    }
  }

  String get toPercentage {
    final fait = this * Decimal.parse('100');
    return '${fait.toStringAsFixed(2)}%';
  }
}

extension AssetResultExtension on AssetResult {
  Decimal get amountOfUsd => balance.asDecimal * priceUsd.asDecimal;

  Decimal get amountOfBtc => balance.asDecimal * priceBtc.asDecimal;

  Decimal get amountOfCurrentCurrency =>
      balance.asDecimal * priceUsd.asDecimal * fiatRate.asDecimal;

  Decimal get usdUnitPrice => priceUsd.asDecimal * fiatRate.asDecimal;

  bool get needShowMemo => tag?.isNotEmpty ?? false;

  bool get needShowReserve => (int.tryParse(reserve ?? '0') ?? 0) > 0;

  List<String> getTip(BuildContext context) {
    switch (assetId) {
      case bitcoin:
        return [context.l10n.depositTipBtc];
      case ethereum:
        return [context.l10n.depositTipEth];
      case eos:
        return [context.l10n.depositTipEos];
      case tron:
        return [
          context.l10n.depositTipTron,
          context.l10n.depositTipNotSupportContract,
        ];
      default:
        return [context.l10n.depositTip(symbol)];
    }
  }
}

extension SnapshotItemExtension on SnapshotItem {
  Decimal amountOfCurrentCurrency(AssetResult asset) {
    assert(asset.assetId == assetId);
    return amount.asDecimal *
        asset.priceUsd.asDecimal *
        asset.fiatRate.asDecimal;
  }

  bool get isPositive => (double.tryParse(amount) ?? 0) > 0;
}

extension AddressExtension on Addresse {
  String displayAddress() {
    if (tag == null || (tag?.isEmpty ?? false)) {
      return '$destination$tag';
    } else {
      return destination;
    }
  }
}
