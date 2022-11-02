import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:uniswap_sdk_dart/uniswap_sdk_dart.dart' as mifiswap;
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
    if (useFennec) {
      bot = sdk.Client(
          userId: fennecUserId,
          sessionId: fennecSessionId,
          privateKey: fennecPrivateKey,
          // scp: authScope,
          interceptors: interceptors,
          httpLogLevel: null);
    }
    if (useMixinMessager) {
      bot = sdk.Client(
          accessToken: accessToken,
          interceptors: interceptors,
          httpLogLevel: null);
    }
    scheduleMicrotask(() async {
      if (isLogin || useFennec) {
        try {
          final response = await bot.accountApi.getMe();
          if (useFennec) {
            await setAuth(Auth(accessToken: 'fennec', account: response.data));
          }
          if (useMixinMessager) {
            await setAuth(
                Auth(accessToken: accessToken!, account: response.data));
          }
        } catch (error) {
          d('refresh account failed. $error');
        }
      }
      await _initDatabase();
      _initCompleter.complete();
    });
    if (useFennec) {
      fswap = mifiswap.Client(
        userId: fennecUserId,
        sessionId: fennecSessionId,
        privateKey: fennecPrivateKey,
        scp: authScope,
        interceptors: interceptors,
      );
    }
    if (useMixinMessager) {
      fswap = mifiswap.Client(accessToken: accessToken);
      mc = MixinClient();
    }
    // Timer.periodic(const Duration(seconds: 5), (timer) async {
    //   await updatePairs();
    // });
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
  late mifiswap.Client fswap;
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
    if (useFennec) {
      return;
    }

    final myDio = Dio();
    myDio.options.baseUrl = mifiswapOauthUrl;
    myDio.options.responseType = ResponseType.json;

    final response = await myDio.post<Map<String, dynamic>>(
      '/oauth/token',
      data: {
        'code': oauthCode,
      },
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );

    final rsp = response.data?['data'] as Map<String, dynamic>?;

    if (rsp == null) {
      throw ArgumentError('scope');
    }

    final scope = (rsp['scope'] as String?) ?? '';
    if (!scope.contains('ASSETS:READ')) {
      throw ArgumentError('scope');
    }

    final token = (rsp['access_token'] as String?) ?? '';

    final bot0 = sdk.Client(accessToken: token, interceptors: interceptors);

    final mixinResponse = await bot0.accountApi.getMe();

    await setAuth(Auth(accessToken: token, account: mixinResponse.data));

    bot = bot0;
    fswap = mifiswap.Client(accessToken: token);
    // await _initDatabase();
    notifyListeners();
  }

  Future<void> _initDatabase() async {
    i('init database start');
    _mixinDatabase = await constructDb('MifiSwap');
    i('init database done');
    notifyListeners();
  }

  void connect(bool Function(String?, String?) callback) {
    if (useFennec) {
      return;
    }
    mc.connect(mifiswapClientId, authScope, callback);
  }

  Future<void> updatePairs() async {
    final pairList = await fswap.readPairs();
    final pairs = pairList.data?.pairs ?? [];
    await mixinDatabase.transaction(() async {
      await mixinDatabase.pairDao.insertAllOnConflictUpdate(pairs);
    });
  }

  Future<void> updateAssets() async {
    final assetList = await fswap.readAssets();
    final assets = assetList.data?.assets
        .where((asset) => !(asset.symbol ?? '').contains('-'))
        .toList();
    await mixinDatabase.transaction(() async {
      await mixinDatabase.assetDao.insertAllOnConflictUpdate(assets ?? []);
    });
  }

  Future<void> updatePairsAndAssets() async {
    await Future.wait([
      updateAssets(),
      updatePairs(),
    ]);
  }

  // Future<mifiswap.Asset> updateAsset(String id) async {
  //   final asset = (await fswap.readAsset(id)).data;
  //   await mixinDatabase.assetDao.insert(asset);
  //   return asset;
  // }

  @override
  Future<void> dispose() async {
    super.dispose();
    final mixinDatabase0 = _mixinDatabase;
    _mixinDatabase = null;
    await mixinDatabase0?.close();
  }

  @override
  List<Object?> get props => [
        bot,
        fswap,
        _mixinDatabase,
      ];
}
