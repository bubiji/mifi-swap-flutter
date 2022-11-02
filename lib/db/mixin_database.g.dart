// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mixin_database.dart';

// **************************************************************************
// DriftDatabaseGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Pair extends DataClass implements Insertable<Pair> {
  final String baseAmount;
  final String baseAssetId;
  final String baseValue;
  final String baseVolume24h;
  final String fee24h;
  final String feePercent;
  final String liquidity;
  final String liquidityAssetId;
  final String maxLiquidity;
  final String quoteAmount;
  final String quoteAssetId;
  final String quoteValue;
  final String quoteVolume24h;
  final int? routeId;
  final String? swapMethod;
  final int? transactionCount24h;
  final int? version;
  final String volume24h;
  const Pair(
      {required this.baseAmount,
      required this.baseAssetId,
      required this.baseValue,
      required this.baseVolume24h,
      required this.fee24h,
      required this.feePercent,
      required this.liquidity,
      required this.liquidityAssetId,
      required this.maxLiquidity,
      required this.quoteAmount,
      required this.quoteAssetId,
      required this.quoteValue,
      required this.quoteVolume24h,
      this.routeId,
      this.swapMethod,
      this.transactionCount24h,
      this.version,
      required this.volume24h});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['base_amount'] = Variable<String>(baseAmount);
    map['base_asset_id'] = Variable<String>(baseAssetId);
    map['base_value'] = Variable<String>(baseValue);
    map['base_volume_24h'] = Variable<String>(baseVolume24h);
    map['fee_24h'] = Variable<String>(fee24h);
    map['fee_percent'] = Variable<String>(feePercent);
    map['liquidity'] = Variable<String>(liquidity);
    map['liquidity_asset_id'] = Variable<String>(liquidityAssetId);
    map['max_liquidity'] = Variable<String>(maxLiquidity);
    map['quote_amount'] = Variable<String>(quoteAmount);
    map['quote_asset_id'] = Variable<String>(quoteAssetId);
    map['quote_value'] = Variable<String>(quoteValue);
    map['quote_volume_24h'] = Variable<String>(quoteVolume24h);
    if (!nullToAbsent || routeId != null) {
      map['route_id'] = Variable<int>(routeId);
    }
    if (!nullToAbsent || swapMethod != null) {
      map['swap_method'] = Variable<String>(swapMethod);
    }
    if (!nullToAbsent || transactionCount24h != null) {
      map['transaction_count_24h'] = Variable<int>(transactionCount24h);
    }
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<int>(version);
    }
    map['volume_24h'] = Variable<String>(volume24h);
    return map;
  }

  PairsCompanion toCompanion(bool nullToAbsent) {
    return PairsCompanion(
      baseAmount: Value(baseAmount),
      baseAssetId: Value(baseAssetId),
      baseValue: Value(baseValue),
      baseVolume24h: Value(baseVolume24h),
      fee24h: Value(fee24h),
      feePercent: Value(feePercent),
      liquidity: Value(liquidity),
      liquidityAssetId: Value(liquidityAssetId),
      maxLiquidity: Value(maxLiquidity),
      quoteAmount: Value(quoteAmount),
      quoteAssetId: Value(quoteAssetId),
      quoteValue: Value(quoteValue),
      quoteVolume24h: Value(quoteVolume24h),
      routeId: routeId == null && nullToAbsent
          ? const Value.absent()
          : Value(routeId),
      swapMethod: swapMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(swapMethod),
      transactionCount24h: transactionCount24h == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionCount24h),
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      volume24h: Value(volume24h),
    );
  }

  factory Pair.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pair(
      baseAmount: serializer.fromJson<String>(json['base_amount']),
      baseAssetId: serializer.fromJson<String>(json['base_asset_id']),
      baseValue: serializer.fromJson<String>(json['base_value']),
      baseVolume24h: serializer.fromJson<String>(json['base_volume_24h']),
      fee24h: serializer.fromJson<String>(json['fee_24h']),
      feePercent: serializer.fromJson<String>(json['fee_percent']),
      liquidity: serializer.fromJson<String>(json['liquidity']),
      liquidityAssetId: serializer.fromJson<String>(json['liquidity_asset_id']),
      maxLiquidity: serializer.fromJson<String>(json['max_liquidity']),
      quoteAmount: serializer.fromJson<String>(json['quote_amount']),
      quoteAssetId: serializer.fromJson<String>(json['quote_asset_id']),
      quoteValue: serializer.fromJson<String>(json['quote_value']),
      quoteVolume24h: serializer.fromJson<String>(json['quote_volume_24h']),
      routeId: serializer.fromJson<int?>(json['route_id']),
      swapMethod: serializer.fromJson<String?>(json['swap_method']),
      transactionCount24h:
          serializer.fromJson<int?>(json['transaction_count_24h']),
      version: serializer.fromJson<int?>(json['version']),
      volume24h: serializer.fromJson<String>(json['volume_24h']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'base_amount': serializer.toJson<String>(baseAmount),
      'base_asset_id': serializer.toJson<String>(baseAssetId),
      'base_value': serializer.toJson<String>(baseValue),
      'base_volume_24h': serializer.toJson<String>(baseVolume24h),
      'fee_24h': serializer.toJson<String>(fee24h),
      'fee_percent': serializer.toJson<String>(feePercent),
      'liquidity': serializer.toJson<String>(liquidity),
      'liquidity_asset_id': serializer.toJson<String>(liquidityAssetId),
      'max_liquidity': serializer.toJson<String>(maxLiquidity),
      'quote_amount': serializer.toJson<String>(quoteAmount),
      'quote_asset_id': serializer.toJson<String>(quoteAssetId),
      'quote_value': serializer.toJson<String>(quoteValue),
      'quote_volume_24h': serializer.toJson<String>(quoteVolume24h),
      'route_id': serializer.toJson<int?>(routeId),
      'swap_method': serializer.toJson<String?>(swapMethod),
      'transaction_count_24h': serializer.toJson<int?>(transactionCount24h),
      'version': serializer.toJson<int?>(version),
      'volume_24h': serializer.toJson<String>(volume24h),
    };
  }

  Pair copyWith(
          {String? baseAmount,
          String? baseAssetId,
          String? baseValue,
          String? baseVolume24h,
          String? fee24h,
          String? feePercent,
          String? liquidity,
          String? liquidityAssetId,
          String? maxLiquidity,
          String? quoteAmount,
          String? quoteAssetId,
          String? quoteValue,
          String? quoteVolume24h,
          Value<int?> routeId = const Value.absent(),
          Value<String?> swapMethod = const Value.absent(),
          Value<int?> transactionCount24h = const Value.absent(),
          Value<int?> version = const Value.absent(),
          String? volume24h}) =>
      Pair(
        baseAmount: baseAmount ?? this.baseAmount,
        baseAssetId: baseAssetId ?? this.baseAssetId,
        baseValue: baseValue ?? this.baseValue,
        baseVolume24h: baseVolume24h ?? this.baseVolume24h,
        fee24h: fee24h ?? this.fee24h,
        feePercent: feePercent ?? this.feePercent,
        liquidity: liquidity ?? this.liquidity,
        liquidityAssetId: liquidityAssetId ?? this.liquidityAssetId,
        maxLiquidity: maxLiquidity ?? this.maxLiquidity,
        quoteAmount: quoteAmount ?? this.quoteAmount,
        quoteAssetId: quoteAssetId ?? this.quoteAssetId,
        quoteValue: quoteValue ?? this.quoteValue,
        quoteVolume24h: quoteVolume24h ?? this.quoteVolume24h,
        routeId: routeId.present ? routeId.value : this.routeId,
        swapMethod: swapMethod.present ? swapMethod.value : this.swapMethod,
        transactionCount24h: transactionCount24h.present
            ? transactionCount24h.value
            : this.transactionCount24h,
        version: version.present ? version.value : this.version,
        volume24h: volume24h ?? this.volume24h,
      );
  @override
  String toString() {
    return (StringBuffer('Pair(')
          ..write('baseAmount: $baseAmount, ')
          ..write('baseAssetId: $baseAssetId, ')
          ..write('baseValue: $baseValue, ')
          ..write('baseVolume24h: $baseVolume24h, ')
          ..write('fee24h: $fee24h, ')
          ..write('feePercent: $feePercent, ')
          ..write('liquidity: $liquidity, ')
          ..write('liquidityAssetId: $liquidityAssetId, ')
          ..write('maxLiquidity: $maxLiquidity, ')
          ..write('quoteAmount: $quoteAmount, ')
          ..write('quoteAssetId: $quoteAssetId, ')
          ..write('quoteValue: $quoteValue, ')
          ..write('quoteVolume24h: $quoteVolume24h, ')
          ..write('routeId: $routeId, ')
          ..write('swapMethod: $swapMethod, ')
          ..write('transactionCount24h: $transactionCount24h, ')
          ..write('version: $version, ')
          ..write('volume24h: $volume24h')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      baseAmount,
      baseAssetId,
      baseValue,
      baseVolume24h,
      fee24h,
      feePercent,
      liquidity,
      liquidityAssetId,
      maxLiquidity,
      quoteAmount,
      quoteAssetId,
      quoteValue,
      quoteVolume24h,
      routeId,
      swapMethod,
      transactionCount24h,
      version,
      volume24h);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pair &&
          other.baseAmount == this.baseAmount &&
          other.baseAssetId == this.baseAssetId &&
          other.baseValue == this.baseValue &&
          other.baseVolume24h == this.baseVolume24h &&
          other.fee24h == this.fee24h &&
          other.feePercent == this.feePercent &&
          other.liquidity == this.liquidity &&
          other.liquidityAssetId == this.liquidityAssetId &&
          other.maxLiquidity == this.maxLiquidity &&
          other.quoteAmount == this.quoteAmount &&
          other.quoteAssetId == this.quoteAssetId &&
          other.quoteValue == this.quoteValue &&
          other.quoteVolume24h == this.quoteVolume24h &&
          other.routeId == this.routeId &&
          other.swapMethod == this.swapMethod &&
          other.transactionCount24h == this.transactionCount24h &&
          other.version == this.version &&
          other.volume24h == this.volume24h);
}

class PairsCompanion extends UpdateCompanion<Pair> {
  final Value<String> baseAmount;
  final Value<String> baseAssetId;
  final Value<String> baseValue;
  final Value<String> baseVolume24h;
  final Value<String> fee24h;
  final Value<String> feePercent;
  final Value<String> liquidity;
  final Value<String> liquidityAssetId;
  final Value<String> maxLiquidity;
  final Value<String> quoteAmount;
  final Value<String> quoteAssetId;
  final Value<String> quoteValue;
  final Value<String> quoteVolume24h;
  final Value<int?> routeId;
  final Value<String?> swapMethod;
  final Value<int?> transactionCount24h;
  final Value<int?> version;
  final Value<String> volume24h;
  const PairsCompanion({
    this.baseAmount = const Value.absent(),
    this.baseAssetId = const Value.absent(),
    this.baseValue = const Value.absent(),
    this.baseVolume24h = const Value.absent(),
    this.fee24h = const Value.absent(),
    this.feePercent = const Value.absent(),
    this.liquidity = const Value.absent(),
    this.liquidityAssetId = const Value.absent(),
    this.maxLiquidity = const Value.absent(),
    this.quoteAmount = const Value.absent(),
    this.quoteAssetId = const Value.absent(),
    this.quoteValue = const Value.absent(),
    this.quoteVolume24h = const Value.absent(),
    this.routeId = const Value.absent(),
    this.swapMethod = const Value.absent(),
    this.transactionCount24h = const Value.absent(),
    this.version = const Value.absent(),
    this.volume24h = const Value.absent(),
  });
  PairsCompanion.insert({
    required String baseAmount,
    required String baseAssetId,
    required String baseValue,
    required String baseVolume24h,
    required String fee24h,
    required String feePercent,
    required String liquidity,
    required String liquidityAssetId,
    required String maxLiquidity,
    required String quoteAmount,
    required String quoteAssetId,
    required String quoteValue,
    required String quoteVolume24h,
    this.routeId = const Value.absent(),
    this.swapMethod = const Value.absent(),
    this.transactionCount24h = const Value.absent(),
    this.version = const Value.absent(),
    required String volume24h,
  })  : baseAmount = Value(baseAmount),
        baseAssetId = Value(baseAssetId),
        baseValue = Value(baseValue),
        baseVolume24h = Value(baseVolume24h),
        fee24h = Value(fee24h),
        feePercent = Value(feePercent),
        liquidity = Value(liquidity),
        liquidityAssetId = Value(liquidityAssetId),
        maxLiquidity = Value(maxLiquidity),
        quoteAmount = Value(quoteAmount),
        quoteAssetId = Value(quoteAssetId),
        quoteValue = Value(quoteValue),
        quoteVolume24h = Value(quoteVolume24h),
        volume24h = Value(volume24h);
  static Insertable<Pair> custom({
    Expression<String>? baseAmount,
    Expression<String>? baseAssetId,
    Expression<String>? baseValue,
    Expression<String>? baseVolume24h,
    Expression<String>? fee24h,
    Expression<String>? feePercent,
    Expression<String>? liquidity,
    Expression<String>? liquidityAssetId,
    Expression<String>? maxLiquidity,
    Expression<String>? quoteAmount,
    Expression<String>? quoteAssetId,
    Expression<String>? quoteValue,
    Expression<String>? quoteVolume24h,
    Expression<int>? routeId,
    Expression<String>? swapMethod,
    Expression<int>? transactionCount24h,
    Expression<int>? version,
    Expression<String>? volume24h,
  }) {
    return RawValuesInsertable({
      if (baseAmount != null) 'base_amount': baseAmount,
      if (baseAssetId != null) 'base_asset_id': baseAssetId,
      if (baseValue != null) 'base_value': baseValue,
      if (baseVolume24h != null) 'base_volume_24h': baseVolume24h,
      if (fee24h != null) 'fee_24h': fee24h,
      if (feePercent != null) 'fee_percent': feePercent,
      if (liquidity != null) 'liquidity': liquidity,
      if (liquidityAssetId != null) 'liquidity_asset_id': liquidityAssetId,
      if (maxLiquidity != null) 'max_liquidity': maxLiquidity,
      if (quoteAmount != null) 'quote_amount': quoteAmount,
      if (quoteAssetId != null) 'quote_asset_id': quoteAssetId,
      if (quoteValue != null) 'quote_value': quoteValue,
      if (quoteVolume24h != null) 'quote_volume_24h': quoteVolume24h,
      if (routeId != null) 'route_id': routeId,
      if (swapMethod != null) 'swap_method': swapMethod,
      if (transactionCount24h != null)
        'transaction_count_24h': transactionCount24h,
      if (version != null) 'version': version,
      if (volume24h != null) 'volume_24h': volume24h,
    });
  }

  PairsCompanion copyWith(
      {Value<String>? baseAmount,
      Value<String>? baseAssetId,
      Value<String>? baseValue,
      Value<String>? baseVolume24h,
      Value<String>? fee24h,
      Value<String>? feePercent,
      Value<String>? liquidity,
      Value<String>? liquidityAssetId,
      Value<String>? maxLiquidity,
      Value<String>? quoteAmount,
      Value<String>? quoteAssetId,
      Value<String>? quoteValue,
      Value<String>? quoteVolume24h,
      Value<int?>? routeId,
      Value<String?>? swapMethod,
      Value<int?>? transactionCount24h,
      Value<int?>? version,
      Value<String>? volume24h}) {
    return PairsCompanion(
      baseAmount: baseAmount ?? this.baseAmount,
      baseAssetId: baseAssetId ?? this.baseAssetId,
      baseValue: baseValue ?? this.baseValue,
      baseVolume24h: baseVolume24h ?? this.baseVolume24h,
      fee24h: fee24h ?? this.fee24h,
      feePercent: feePercent ?? this.feePercent,
      liquidity: liquidity ?? this.liquidity,
      liquidityAssetId: liquidityAssetId ?? this.liquidityAssetId,
      maxLiquidity: maxLiquidity ?? this.maxLiquidity,
      quoteAmount: quoteAmount ?? this.quoteAmount,
      quoteAssetId: quoteAssetId ?? this.quoteAssetId,
      quoteValue: quoteValue ?? this.quoteValue,
      quoteVolume24h: quoteVolume24h ?? this.quoteVolume24h,
      routeId: routeId ?? this.routeId,
      swapMethod: swapMethod ?? this.swapMethod,
      transactionCount24h: transactionCount24h ?? this.transactionCount24h,
      version: version ?? this.version,
      volume24h: volume24h ?? this.volume24h,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (baseAmount.present) {
      map['base_amount'] = Variable<String>(baseAmount.value);
    }
    if (baseAssetId.present) {
      map['base_asset_id'] = Variable<String>(baseAssetId.value);
    }
    if (baseValue.present) {
      map['base_value'] = Variable<String>(baseValue.value);
    }
    if (baseVolume24h.present) {
      map['base_volume_24h'] = Variable<String>(baseVolume24h.value);
    }
    if (fee24h.present) {
      map['fee_24h'] = Variable<String>(fee24h.value);
    }
    if (feePercent.present) {
      map['fee_percent'] = Variable<String>(feePercent.value);
    }
    if (liquidity.present) {
      map['liquidity'] = Variable<String>(liquidity.value);
    }
    if (liquidityAssetId.present) {
      map['liquidity_asset_id'] = Variable<String>(liquidityAssetId.value);
    }
    if (maxLiquidity.present) {
      map['max_liquidity'] = Variable<String>(maxLiquidity.value);
    }
    if (quoteAmount.present) {
      map['quote_amount'] = Variable<String>(quoteAmount.value);
    }
    if (quoteAssetId.present) {
      map['quote_asset_id'] = Variable<String>(quoteAssetId.value);
    }
    if (quoteValue.present) {
      map['quote_value'] = Variable<String>(quoteValue.value);
    }
    if (quoteVolume24h.present) {
      map['quote_volume_24h'] = Variable<String>(quoteVolume24h.value);
    }
    if (routeId.present) {
      map['route_id'] = Variable<int>(routeId.value);
    }
    if (swapMethod.present) {
      map['swap_method'] = Variable<String>(swapMethod.value);
    }
    if (transactionCount24h.present) {
      map['transaction_count_24h'] = Variable<int>(transactionCount24h.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (volume24h.present) {
      map['volume_24h'] = Variable<String>(volume24h.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PairsCompanion(')
          ..write('baseAmount: $baseAmount, ')
          ..write('baseAssetId: $baseAssetId, ')
          ..write('baseValue: $baseValue, ')
          ..write('baseVolume24h: $baseVolume24h, ')
          ..write('fee24h: $fee24h, ')
          ..write('feePercent: $feePercent, ')
          ..write('liquidity: $liquidity, ')
          ..write('liquidityAssetId: $liquidityAssetId, ')
          ..write('maxLiquidity: $maxLiquidity, ')
          ..write('quoteAmount: $quoteAmount, ')
          ..write('quoteAssetId: $quoteAssetId, ')
          ..write('quoteValue: $quoteValue, ')
          ..write('quoteVolume24h: $quoteVolume24h, ')
          ..write('routeId: $routeId, ')
          ..write('swapMethod: $swapMethod, ')
          ..write('transactionCount24h: $transactionCount24h, ')
          ..write('version: $version, ')
          ..write('volume24h: $volume24h')
          ..write(')'))
        .toString();
  }
}

class Pairs extends Table with TableInfo<Pairs, Pair> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Pairs(this.attachedDatabase, [this._alias]);
  final VerificationMeta _baseAmountMeta = const VerificationMeta('baseAmount');
  late final GeneratedColumn<String> baseAmount = GeneratedColumn<String>(
      'base_amount', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _baseAssetIdMeta =
      const VerificationMeta('baseAssetId');
  late final GeneratedColumn<String> baseAssetId = GeneratedColumn<String>(
      'base_asset_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _baseValueMeta = const VerificationMeta('baseValue');
  late final GeneratedColumn<String> baseValue = GeneratedColumn<String>(
      'base_value', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _baseVolume24hMeta =
      const VerificationMeta('baseVolume24h');
  late final GeneratedColumn<String> baseVolume24h = GeneratedColumn<String>(
      'base_volume_24h', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _fee24hMeta = const VerificationMeta('fee24h');
  late final GeneratedColumn<String> fee24h = GeneratedColumn<String>(
      'fee_24h', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _feePercentMeta = const VerificationMeta('feePercent');
  late final GeneratedColumn<String> feePercent = GeneratedColumn<String>(
      'fee_percent', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _liquidityMeta = const VerificationMeta('liquidity');
  late final GeneratedColumn<String> liquidity = GeneratedColumn<String>(
      'liquidity', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _liquidityAssetIdMeta =
      const VerificationMeta('liquidityAssetId');
  late final GeneratedColumn<String> liquidityAssetId = GeneratedColumn<String>(
      'liquidity_asset_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _maxLiquidityMeta =
      const VerificationMeta('maxLiquidity');
  late final GeneratedColumn<String> maxLiquidity = GeneratedColumn<String>(
      'max_liquidity', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _quoteAmountMeta =
      const VerificationMeta('quoteAmount');
  late final GeneratedColumn<String> quoteAmount = GeneratedColumn<String>(
      'quote_amount', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _quoteAssetIdMeta =
      const VerificationMeta('quoteAssetId');
  late final GeneratedColumn<String> quoteAssetId = GeneratedColumn<String>(
      'quote_asset_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _quoteValueMeta = const VerificationMeta('quoteValue');
  late final GeneratedColumn<String> quoteValue = GeneratedColumn<String>(
      'quote_value', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _quoteVolume24hMeta =
      const VerificationMeta('quoteVolume24h');
  late final GeneratedColumn<String> quoteVolume24h = GeneratedColumn<String>(
      'quote_volume_24h', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _routeIdMeta = const VerificationMeta('routeId');
  late final GeneratedColumn<int> routeId = GeneratedColumn<int>(
      'route_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  final VerificationMeta _swapMethodMeta = const VerificationMeta('swapMethod');
  late final GeneratedColumn<String> swapMethod = GeneratedColumn<String>(
      'swap_method', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  final VerificationMeta _transactionCount24hMeta =
      const VerificationMeta('transactionCount24h');
  late final GeneratedColumn<int> transactionCount24h = GeneratedColumn<int>(
      'transaction_count_24h', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  final VerificationMeta _versionMeta = const VerificationMeta('version');
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  final VerificationMeta _volume24hMeta = const VerificationMeta('volume24h');
  late final GeneratedColumn<String> volume24h = GeneratedColumn<String>(
      'volume_24h', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [
        baseAmount,
        baseAssetId,
        baseValue,
        baseVolume24h,
        fee24h,
        feePercent,
        liquidity,
        liquidityAssetId,
        maxLiquidity,
        quoteAmount,
        quoteAssetId,
        quoteValue,
        quoteVolume24h,
        routeId,
        swapMethod,
        transactionCount24h,
        version,
        volume24h
      ];
  @override
  String get aliasedName => _alias ?? 'pairs';
  @override
  String get actualTableName => 'pairs';
  @override
  VerificationContext validateIntegrity(Insertable<Pair> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('base_amount')) {
      context.handle(
          _baseAmountMeta,
          baseAmount.isAcceptableOrUnknown(
              data['base_amount']!, _baseAmountMeta));
    } else if (isInserting) {
      context.missing(_baseAmountMeta);
    }
    if (data.containsKey('base_asset_id')) {
      context.handle(
          _baseAssetIdMeta,
          baseAssetId.isAcceptableOrUnknown(
              data['base_asset_id']!, _baseAssetIdMeta));
    } else if (isInserting) {
      context.missing(_baseAssetIdMeta);
    }
    if (data.containsKey('base_value')) {
      context.handle(_baseValueMeta,
          baseValue.isAcceptableOrUnknown(data['base_value']!, _baseValueMeta));
    } else if (isInserting) {
      context.missing(_baseValueMeta);
    }
    if (data.containsKey('base_volume_24h')) {
      context.handle(
          _baseVolume24hMeta,
          baseVolume24h.isAcceptableOrUnknown(
              data['base_volume_24h']!, _baseVolume24hMeta));
    } else if (isInserting) {
      context.missing(_baseVolume24hMeta);
    }
    if (data.containsKey('fee_24h')) {
      context.handle(_fee24hMeta,
          fee24h.isAcceptableOrUnknown(data['fee_24h']!, _fee24hMeta));
    } else if (isInserting) {
      context.missing(_fee24hMeta);
    }
    if (data.containsKey('fee_percent')) {
      context.handle(
          _feePercentMeta,
          feePercent.isAcceptableOrUnknown(
              data['fee_percent']!, _feePercentMeta));
    } else if (isInserting) {
      context.missing(_feePercentMeta);
    }
    if (data.containsKey('liquidity')) {
      context.handle(_liquidityMeta,
          liquidity.isAcceptableOrUnknown(data['liquidity']!, _liquidityMeta));
    } else if (isInserting) {
      context.missing(_liquidityMeta);
    }
    if (data.containsKey('liquidity_asset_id')) {
      context.handle(
          _liquidityAssetIdMeta,
          liquidityAssetId.isAcceptableOrUnknown(
              data['liquidity_asset_id']!, _liquidityAssetIdMeta));
    } else if (isInserting) {
      context.missing(_liquidityAssetIdMeta);
    }
    if (data.containsKey('max_liquidity')) {
      context.handle(
          _maxLiquidityMeta,
          maxLiquidity.isAcceptableOrUnknown(
              data['max_liquidity']!, _maxLiquidityMeta));
    } else if (isInserting) {
      context.missing(_maxLiquidityMeta);
    }
    if (data.containsKey('quote_amount')) {
      context.handle(
          _quoteAmountMeta,
          quoteAmount.isAcceptableOrUnknown(
              data['quote_amount']!, _quoteAmountMeta));
    } else if (isInserting) {
      context.missing(_quoteAmountMeta);
    }
    if (data.containsKey('quote_asset_id')) {
      context.handle(
          _quoteAssetIdMeta,
          quoteAssetId.isAcceptableOrUnknown(
              data['quote_asset_id']!, _quoteAssetIdMeta));
    } else if (isInserting) {
      context.missing(_quoteAssetIdMeta);
    }
    if (data.containsKey('quote_value')) {
      context.handle(
          _quoteValueMeta,
          quoteValue.isAcceptableOrUnknown(
              data['quote_value']!, _quoteValueMeta));
    } else if (isInserting) {
      context.missing(_quoteValueMeta);
    }
    if (data.containsKey('quote_volume_24h')) {
      context.handle(
          _quoteVolume24hMeta,
          quoteVolume24h.isAcceptableOrUnknown(
              data['quote_volume_24h']!, _quoteVolume24hMeta));
    } else if (isInserting) {
      context.missing(_quoteVolume24hMeta);
    }
    if (data.containsKey('route_id')) {
      context.handle(_routeIdMeta,
          routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta));
    }
    if (data.containsKey('swap_method')) {
      context.handle(
          _swapMethodMeta,
          swapMethod.isAcceptableOrUnknown(
              data['swap_method']!, _swapMethodMeta));
    }
    if (data.containsKey('transaction_count_24h')) {
      context.handle(
          _transactionCount24hMeta,
          transactionCount24h.isAcceptableOrUnknown(
              data['transaction_count_24h']!, _transactionCount24hMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('volume_24h')) {
      context.handle(_volume24hMeta,
          volume24h.isAcceptableOrUnknown(data['volume_24h']!, _volume24hMeta));
    } else if (isInserting) {
      context.missing(_volume24hMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {baseAssetId, quoteAssetId};
  @override
  Pair map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pair(
      baseAmount: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}base_amount'])!,
      baseAssetId: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}base_asset_id'])!,
      baseValue: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}base_value'])!,
      baseVolume24h: attachedDatabase.options.types.read(
          DriftSqlType.string, data['${effectivePrefix}base_volume_24h'])!,
      fee24h: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}fee_24h'])!,
      feePercent: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}fee_percent'])!,
      liquidity: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}liquidity'])!,
      liquidityAssetId: attachedDatabase.options.types.read(
          DriftSqlType.string, data['${effectivePrefix}liquidity_asset_id'])!,
      maxLiquidity: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}max_liquidity'])!,
      quoteAmount: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}quote_amount'])!,
      quoteAssetId: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}quote_asset_id'])!,
      quoteValue: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}quote_value'])!,
      quoteVolume24h: attachedDatabase.options.types.read(
          DriftSqlType.string, data['${effectivePrefix}quote_volume_24h'])!,
      routeId: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}route_id']),
      swapMethod: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}swap_method']),
      transactionCount24h: attachedDatabase.options.types.read(
          DriftSqlType.int, data['${effectivePrefix}transaction_count_24h']),
      version: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}version']),
      volume24h: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}volume_24h'])!,
    );
  }

  @override
  Pairs createAlias(String alias) {
    return Pairs(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints =>
      const ['PRIMARY KEY(base_asset_id, quote_asset_id)'];
  @override
  bool get dontWriteConstraints => true;
}

class Asset extends DataClass implements Insertable<Asset> {
  final String id;
  final String logo;
  final String name;
  final String price;
  final String? symbol;
  final String? extra;
  final String chainId;
  final String? chainSymbol;
  final String chainLogo;
  final String chainName;
  const Asset(
      {required this.id,
      required this.logo,
      required this.name,
      required this.price,
      this.symbol,
      this.extra,
      required this.chainId,
      this.chainSymbol,
      required this.chainLogo,
      required this.chainName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['logo'] = Variable<String>(logo);
    map['name'] = Variable<String>(name);
    map['price'] = Variable<String>(price);
    if (!nullToAbsent || symbol != null) {
      map['symbol'] = Variable<String>(symbol);
    }
    if (!nullToAbsent || extra != null) {
      map['extra'] = Variable<String>(extra);
    }
    map['chain_id'] = Variable<String>(chainId);
    if (!nullToAbsent || chainSymbol != null) {
      map['chain_symbol'] = Variable<String>(chainSymbol);
    }
    map['chain_logo'] = Variable<String>(chainLogo);
    map['chain_name'] = Variable<String>(chainName);
    return map;
  }

  AssetsCompanion toCompanion(bool nullToAbsent) {
    return AssetsCompanion(
      id: Value(id),
      logo: Value(logo),
      name: Value(name),
      price: Value(price),
      symbol:
          symbol == null && nullToAbsent ? const Value.absent() : Value(symbol),
      extra:
          extra == null && nullToAbsent ? const Value.absent() : Value(extra),
      chainId: Value(chainId),
      chainSymbol: chainSymbol == null && nullToAbsent
          ? const Value.absent()
          : Value(chainSymbol),
      chainLogo: Value(chainLogo),
      chainName: Value(chainName),
    );
  }

  factory Asset.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Asset(
      id: serializer.fromJson<String>(json['id']),
      logo: serializer.fromJson<String>(json['logo']),
      name: serializer.fromJson<String>(json['name']),
      price: serializer.fromJson<String>(json['price']),
      symbol: serializer.fromJson<String?>(json['symbol']),
      extra: serializer.fromJson<String?>(json['extra']),
      chainId: serializer.fromJson<String>(json['chain_id']),
      chainSymbol: serializer.fromJson<String?>(json['chain_symbol']),
      chainLogo: serializer.fromJson<String>(json['chain_logo']),
      chainName: serializer.fromJson<String>(json['chain_name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'logo': serializer.toJson<String>(logo),
      'name': serializer.toJson<String>(name),
      'price': serializer.toJson<String>(price),
      'symbol': serializer.toJson<String?>(symbol),
      'extra': serializer.toJson<String?>(extra),
      'chain_id': serializer.toJson<String>(chainId),
      'chain_symbol': serializer.toJson<String?>(chainSymbol),
      'chain_logo': serializer.toJson<String>(chainLogo),
      'chain_name': serializer.toJson<String>(chainName),
    };
  }

  Asset copyWith(
          {String? id,
          String? logo,
          String? name,
          String? price,
          Value<String?> symbol = const Value.absent(),
          Value<String?> extra = const Value.absent(),
          String? chainId,
          Value<String?> chainSymbol = const Value.absent(),
          String? chainLogo,
          String? chainName}) =>
      Asset(
        id: id ?? this.id,
        logo: logo ?? this.logo,
        name: name ?? this.name,
        price: price ?? this.price,
        symbol: symbol.present ? symbol.value : this.symbol,
        extra: extra.present ? extra.value : this.extra,
        chainId: chainId ?? this.chainId,
        chainSymbol: chainSymbol.present ? chainSymbol.value : this.chainSymbol,
        chainLogo: chainLogo ?? this.chainLogo,
        chainName: chainName ?? this.chainName,
      );
  @override
  String toString() {
    return (StringBuffer('Asset(')
          ..write('id: $id, ')
          ..write('logo: $logo, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('symbol: $symbol, ')
          ..write('extra: $extra, ')
          ..write('chainId: $chainId, ')
          ..write('chainSymbol: $chainSymbol, ')
          ..write('chainLogo: $chainLogo, ')
          ..write('chainName: $chainName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, logo, name, price, symbol, extra, chainId,
      chainSymbol, chainLogo, chainName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Asset &&
          other.id == this.id &&
          other.logo == this.logo &&
          other.name == this.name &&
          other.price == this.price &&
          other.symbol == this.symbol &&
          other.extra == this.extra &&
          other.chainId == this.chainId &&
          other.chainSymbol == this.chainSymbol &&
          other.chainLogo == this.chainLogo &&
          other.chainName == this.chainName);
}

class AssetsCompanion extends UpdateCompanion<Asset> {
  final Value<String> id;
  final Value<String> logo;
  final Value<String> name;
  final Value<String> price;
  final Value<String?> symbol;
  final Value<String?> extra;
  final Value<String> chainId;
  final Value<String?> chainSymbol;
  final Value<String> chainLogo;
  final Value<String> chainName;
  const AssetsCompanion({
    this.id = const Value.absent(),
    this.logo = const Value.absent(),
    this.name = const Value.absent(),
    this.price = const Value.absent(),
    this.symbol = const Value.absent(),
    this.extra = const Value.absent(),
    this.chainId = const Value.absent(),
    this.chainSymbol = const Value.absent(),
    this.chainLogo = const Value.absent(),
    this.chainName = const Value.absent(),
  });
  AssetsCompanion.insert({
    required String id,
    required String logo,
    required String name,
    required String price,
    this.symbol = const Value.absent(),
    this.extra = const Value.absent(),
    required String chainId,
    this.chainSymbol = const Value.absent(),
    required String chainLogo,
    required String chainName,
  })  : id = Value(id),
        logo = Value(logo),
        name = Value(name),
        price = Value(price),
        chainId = Value(chainId),
        chainLogo = Value(chainLogo),
        chainName = Value(chainName);
  static Insertable<Asset> custom({
    Expression<String>? id,
    Expression<String>? logo,
    Expression<String>? name,
    Expression<String>? price,
    Expression<String>? symbol,
    Expression<String>? extra,
    Expression<String>? chainId,
    Expression<String>? chainSymbol,
    Expression<String>? chainLogo,
    Expression<String>? chainName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (logo != null) 'logo': logo,
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (symbol != null) 'symbol': symbol,
      if (extra != null) 'extra': extra,
      if (chainId != null) 'chain_id': chainId,
      if (chainSymbol != null) 'chain_symbol': chainSymbol,
      if (chainLogo != null) 'chain_logo': chainLogo,
      if (chainName != null) 'chain_name': chainName,
    });
  }

  AssetsCompanion copyWith(
      {Value<String>? id,
      Value<String>? logo,
      Value<String>? name,
      Value<String>? price,
      Value<String?>? symbol,
      Value<String?>? extra,
      Value<String>? chainId,
      Value<String?>? chainSymbol,
      Value<String>? chainLogo,
      Value<String>? chainName}) {
    return AssetsCompanion(
      id: id ?? this.id,
      logo: logo ?? this.logo,
      name: name ?? this.name,
      price: price ?? this.price,
      symbol: symbol ?? this.symbol,
      extra: extra ?? this.extra,
      chainId: chainId ?? this.chainId,
      chainSymbol: chainSymbol ?? this.chainSymbol,
      chainLogo: chainLogo ?? this.chainLogo,
      chainName: chainName ?? this.chainName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (logo.present) {
      map['logo'] = Variable<String>(logo.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (price.present) {
      map['price'] = Variable<String>(price.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (extra.present) {
      map['extra'] = Variable<String>(extra.value);
    }
    if (chainId.present) {
      map['chain_id'] = Variable<String>(chainId.value);
    }
    if (chainSymbol.present) {
      map['chain_symbol'] = Variable<String>(chainSymbol.value);
    }
    if (chainLogo.present) {
      map['chain_logo'] = Variable<String>(chainLogo.value);
    }
    if (chainName.present) {
      map['chain_name'] = Variable<String>(chainName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetsCompanion(')
          ..write('id: $id, ')
          ..write('logo: $logo, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('symbol: $symbol, ')
          ..write('extra: $extra, ')
          ..write('chainId: $chainId, ')
          ..write('chainSymbol: $chainSymbol, ')
          ..write('chainLogo: $chainLogo, ')
          ..write('chainName: $chainName')
          ..write(')'))
        .toString();
  }
}

class Assets extends Table with TableInfo<Assets, Asset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Assets(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _logoMeta = const VerificationMeta('logo');
  late final GeneratedColumn<String> logo = GeneratedColumn<String>(
      'logo', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _priceMeta = const VerificationMeta('price');
  late final GeneratedColumn<String> price = GeneratedColumn<String>(
      'price', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  final VerificationMeta _extraMeta = const VerificationMeta('extra');
  late final GeneratedColumn<String> extra = GeneratedColumn<String>(
      'extra', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  final VerificationMeta _chainIdMeta = const VerificationMeta('chainId');
  late final GeneratedColumn<String> chainId = GeneratedColumn<String>(
      'chain_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _chainSymbolMeta =
      const VerificationMeta('chainSymbol');
  late final GeneratedColumn<String> chainSymbol = GeneratedColumn<String>(
      'chain_symbol', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  final VerificationMeta _chainLogoMeta = const VerificationMeta('chainLogo');
  late final GeneratedColumn<String> chainLogo = GeneratedColumn<String>(
      'chain_logo', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  final VerificationMeta _chainNameMeta = const VerificationMeta('chainName');
  late final GeneratedColumn<String> chainName = GeneratedColumn<String>(
      'chain_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [
        id,
        logo,
        name,
        price,
        symbol,
        extra,
        chainId,
        chainSymbol,
        chainLogo,
        chainName
      ];
  @override
  String get aliasedName => _alias ?? 'assets';
  @override
  String get actualTableName => 'assets';
  @override
  VerificationContext validateIntegrity(Insertable<Asset> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('logo')) {
      context.handle(
          _logoMeta, logo.isAcceptableOrUnknown(data['logo']!, _logoMeta));
    } else if (isInserting) {
      context.missing(_logoMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    }
    if (data.containsKey('extra')) {
      context.handle(
          _extraMeta, extra.isAcceptableOrUnknown(data['extra']!, _extraMeta));
    }
    if (data.containsKey('chain_id')) {
      context.handle(_chainIdMeta,
          chainId.isAcceptableOrUnknown(data['chain_id']!, _chainIdMeta));
    } else if (isInserting) {
      context.missing(_chainIdMeta);
    }
    if (data.containsKey('chain_symbol')) {
      context.handle(
          _chainSymbolMeta,
          chainSymbol.isAcceptableOrUnknown(
              data['chain_symbol']!, _chainSymbolMeta));
    }
    if (data.containsKey('chain_logo')) {
      context.handle(_chainLogoMeta,
          chainLogo.isAcceptableOrUnknown(data['chain_logo']!, _chainLogoMeta));
    } else if (isInserting) {
      context.missing(_chainLogoMeta);
    }
    if (data.containsKey('chain_name')) {
      context.handle(_chainNameMeta,
          chainName.isAcceptableOrUnknown(data['chain_name']!, _chainNameMeta));
    } else if (isInserting) {
      context.missing(_chainNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Asset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Asset(
      id: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      logo: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}logo'])!,
      name: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      price: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}price'])!,
      symbol: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}symbol']),
      extra: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}extra']),
      chainId: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}chain_id'])!,
      chainSymbol: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}chain_symbol']),
      chainLogo: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}chain_logo'])!,
      chainName: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}chain_name'])!,
    );
  }

  @override
  Assets createAlias(String alias) {
    return Assets(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY(id)'];
  @override
  bool get dontWriteConstraints => true;
}

abstract class _$MixinDatabase extends GeneratedDatabase {
  _$MixinDatabase(QueryExecutor e) : super(e);
  _$MixinDatabase.connect(DatabaseConnection c) : super.connect(c);
  late final Pairs pairs = Pairs(this);
  late final Assets assets = Assets(this);
  late final PairDao pairDao = PairDao(this as MixinDatabase);
  late final AssetDao assetDao = AssetDao(this as MixinDatabase);
  @override
  Iterable<TableInfo<Table, dynamic>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [pairs, assets];
}
