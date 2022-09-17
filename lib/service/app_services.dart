import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:uniswap_sdk_dart/uniswap_sdk_dart.dart' as forswap;
import 'package:vrouter/vrouter.dart';

import './blaze.dart';
import '../db/mixin_database.dart';
import '../db/web/construct_db.dart';
import '../util/constants.dart';
import '../util/logger.dart';
import 'profile/auth.dart';
import 'profile/profile_manager.dart';

class AppServices extends ChangeNotifier with EquatableMixin {
  AppServices({
    required this.vRouterStateKey,
  }) {
    bot = sdk.Client(
        accessToken: accessToken,
        interceptors: interceptors,
        httpLogLevel: null);
    scheduleMicrotask(() async {
      if (isLogin) {
        try {
          final response = await bot.accountApi.getMe();
          await setAuth(
              Auth(accessToken: accessToken!, account: response.data));
        } catch (error) {
          d('refresh account failed. $error');
        }
      }
      await _initDatabase();
      _initCompleter.complete();
    });
    fswap = forswap.Client(
        BaseOptions(headers: {'Authorization': 'Bearer $accessToken'}));
    mc = MixinClient();
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      await updatePairs();
    });
  }

  List<InterceptorsWrapper> get interceptors => [
        InterceptorsWrapper(
          onError: (
            DioError e,
            ErrorInterceptorHandler handler,
          ) async {
            if (e is sdk.MixinApiError &&
                (e.error as sdk.MixinError).code == sdk.authentication) {
              i('api error code is 401 ');
              await setAuth(null);
              // vRouterStateKey.currentState?.to('/auth', isReplacement: true);
            }
            handler.next(e);
          },
        )
      ];

  final GlobalKey<VRouterState> vRouterStateKey;
  late sdk.Client bot;
  late forswap.Client fswap;
  late MixinClient mc;

  final _initCompleter = Completer();

  // ignore: strict_raw_type
  Future? get initServiceFuture => _initCompleter.future;
  MixinDatabase? _mixinDatabase;

  bool get databaseInitialized => _mixinDatabase != null;

  MixinDatabase get mixinDatabase {
    if (!databaseInitialized) {
      throw StateError('the database is not initialized');
    }
    return _mixinDatabase!;
  }

  Future<void> login(String oauthCode) async {
    final response = await fswap.authorization(oauthCode);

    final scope = response.data?.scope ?? '';
    if (!scope.contains('ASSETS:READ')) {
      throw ArgumentError('scope');
    }

    final token = response.data?.token ?? '';

    final _bot = sdk.Client(accessToken: token, interceptors: interceptors);

    final mixinResponse = await _bot.accountApi.getMe();

    await setAuth(Auth(accessToken: token, account: mixinResponse.data));

    bot = _bot;
    fswap = forswap.Client(
        BaseOptions(headers: {'Authorization': 'Bearer $token'}));
    // await _initDatabase();
    notifyListeners();
  }

  Future<void> _initDatabase() async {
    // if (accessToken == null) return;
    i('init database start');
    // _mixinDatabase = await constructDb(auth!.account.identityNumber);
    _mixinDatabase = await constructDb('4swap');
    i('init database done');
    notifyListeners();
  }

  void connect(bool Function(String?, String?) callback) {
    mc.connect('a753e0eb-3010-4c4a-a7b2-a7bda4063f62', authScope, callback);
  }

  Future<void> updatePairs() async {
    final list = await Future.wait([
      fswap.readAssets(),
      fswap.readPairs(),
    ]);
    final assetList =
        (list.first as forswap.UniResponse<forswap.AssetList>).data;
    final pairList = (list.last as forswap.UniResponse<forswap.PairList>).data;
    final assets = assetList?.assets
        .where((asset) => !(asset.symbol ?? '').contains('-'))
        .toList();
    final pairs = pairList?.pairs;
    await mixinDatabase.transaction(() async {
      await mixinDatabase.pairDao.insertAllOnConflictUpdate(pairs ?? []);
      await mixinDatabase.assetDao.insertAllOnConflictUpdate(assets ?? []);
    });
  }

  // Future<forswap.Asset> updateAsset(String id) async {
  //   final asset = (await fswap.readAsset(id)).data;
  //   await mixinDatabase.assetDao.insert(asset);
  //   return asset;
  // }

  @override
  Future<void> dispose() async {
    super.dispose();
    final __mixinDatabase = _mixinDatabase;
    _mixinDatabase = null;
    await __mixinDatabase?.close();
  }

  @override
  List<Object?> get props => [
        bot,
        fswap,
        _mixinDatabase,
      ];
}
