import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:pointycastle/digests/sha3.dart';
import 'package:uniswap_sdk_dart/uniswap_sdk_dart.dart' as mifiswap;
import 'package:vrouter/vrouter.dart';

import './blaze.dart';
import '../db/mixin_database.dart';
import '../db/web/construct_db.dart';
import '../mixin_wallet/db/dao/extension.dart';
import '../mixin_wallet/db/dao/snapshot_dao.dart';
import '../mixin_wallet/db/dao/user_dao.dart';
import '../mixin_wallet/service/profile/auth.dart';
import '../mixin_wallet/util/constants.dart';
import '../util/constants.dart';
import '../util/extension/extension.dart';
import '../util/logger.dart';
import 'profile/keystore.dart';
import 'profile/profile_manager.dart';

class AppServices extends ChangeNotifier with EquatableMixin {
  AppServices({
    required this.vRouterStateKey,
  }) {
    // if (useMixinMessager) {
    //   bot = sdk.Client(
    //       accessToken: accessToken,
    //       interceptors: interceptors,
    //       httpLogLevel: null);

    //   fswap = mifiswap.Client(accessToken: accessToken);
    // }
    scheduleMicrotask(() async {
      final keystore = await getKeyStore();
      if (keystore != null) {
        client = getClientWithKeyStore(keystore);
      }
      // if (useFennec) {
      bot = sdk.Client(
          userId: keystore?.clientId,
          sessionId: keystore?.sessionId,
          privateKey: keystore?.privateKey,
          // scp: authScope,
          interceptors: interceptors,
          httpLogLevel: null);

      fswap = mifiswap.Client(
        userId: keystore?.clientId,
        sessionId: keystore?.sessionId,
        privateKey: keystore?.privateKey,
        scp: authScope,
        interceptors: interceptors,
      );
      // }

      if (isLogin || keystore != null) {
        try {
          final response = await bot.accountApi.getMe();
          // if (useFennec) {
          await setAuth(Auth(accessToken: 'fennec', account: response.data));
          // }
          // if (useMixinMessager) {
          //   await setAuth(
          //       Auth(accessToken: accessToken, account: response.data));
          // }
        } catch (error) {
          d('refresh account failed. $error');
        }
      }
      await _initDatabase();
      timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        try {
          await updateSwapPairs();
          final keystore = await getKeyStore();
          if (keystore != null) {
            await updateAssets();
          }
        } catch (err) {
          // e('$err');
        }
      });
      _initCompleter.complete();
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
  late sdk.Client client;
  late mifiswap.Client fswap;
  MixinClient mc = MixinClient();
  late Timer timer;

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

  Future<void> loginWithKeyStore(KeyStore keystore) async {
    bot = getClientWithKeyStore(keystore);
    client = getClientWithKeyStore(keystore);

    fswap = mifiswap.Client(
      userId: keystore.clientId,
      sessionId: keystore.sessionId,
      privateKey: keystore.privateKey,
      scp: authScope,
      interceptors: interceptors,
    );

    final mixinResponse = await bot.accountApi.getMe();
    await setAuth(Auth(accessToken: 'fennec', account: mixinResponse.data));
    notifyListeners();
  }

  Future<String> getAccessToken(String oauthCode) async {
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

    final rsp = response.data;

    if (rsp == null) {
      throw ArgumentError('scope');
    }

    // final scope = (rsp['scope'] as String?) ?? '';
    // if (!scope.contains('ASSETS:READ')) {
    //   throw ArgumentError('scope');
    // }

    return rsp['access_token'] as String? ?? '';
  }

  // Future<void> login(String oauthCode) async {
  //   final token = await getAccessToken(oauthCode);
  //   final bot0 = sdk.Client(accessToken: token, interceptors: interceptors);

  //   final mixinResponse = await bot0.accountApi.getMe();

  //   await setAuth(Auth(accessToken: token, account: mixinResponse.data));
  //   await setMixinAuth(Auth(accessToken: token, account: mixinResponse.data));

  //   bot = bot0;
  //   fswap = mifiswap.Client(accessToken: token);
  //   notifyListeners();
  // }

  Future<void> bindMixinUser(String oauthCode) async {
    final token = await getAccessToken(oauthCode);
    final bot0 = sdk.Client(accessToken: token, interceptors: interceptors);
    final mixinResponse = await bot0.accountApi.getMe();
    await setMixinAuth(Auth(accessToken: token, account: mixinResponse.data));
    notifyListeners();
  }

  Future<void> _initDatabase() async {
    i('init database start');
    _mixinDatabase = await constructDb('MifiSwap');
    i('init database done');
    notifyListeners();
  }

  void connect(String scope, bool Function(String?, String?) callback) {
    mc.connect(mifiswapClientId, scope, callback);
  }

  Future<void> updateSwapPairs() async {
    final swapPairList = await fswap.readPairs();
    final swapPairs = swapPairList.data?.pairs ?? [];
    await mixinDatabase.transaction(() async {
      await mixinDatabase.swapPairDao.insertAllOnConflictUpdate(swapPairs);
    });
  }

  Future<void> updateSwapAssets() async {
    final swapAssetList = await fswap.readAssets();
    final swapAssets = swapAssetList.data?.assets
        .where((swapAsset) => !(swapAsset.symbol ?? '').contains('-'))
        .toList();
    await mixinDatabase.transaction(() async {
      await mixinDatabase.swapAssetDao
          .insertAllOnConflictUpdate(swapAssets ?? []);
    });
  }

  Future<void> updateSwapPairsAndSwapAssets() async {
    await Future.wait([
      updateSwapAssets(),
      updateSwapPairs(),
    ]);
  }

  // Future<mifiswap.Asset> updateSwapAsset(String id) async {
  //   final swapAsset = (await fswap.readSwapAsset(id)).data;
  //   await mixinDatabase.swapAssetDao.insert(swapAsset);
  //   return swapAsset;
  // }

  Future<KeyStore?> createKeyStore(String fullName) async {
    final keyPair = ed.generateKey();
    final sessionSecret =
        base64Url.encode(keyPair.publicKey.bytes).replaceAll('=', '');
    final privateKey =
        base64Url.encode(keyPair.privateKey.bytes).replaceAll('=', '');

    final myDio = Dio();
    myDio.options.baseUrl = mifiswapOauthUrl;
    myDio.options.responseType = ResponseType.json;

    final response = await myDio.post<Map<String, dynamic>>(
      '/users',
      data: {
        'session_secret': sessionSecret,
        'full_name': fullName,
      },
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );

    final rsp = response.data;

    if (rsp == null) {
      return null;
    }

    final pinTokenBase64 = rsp['pin_token_base64'] as String?;
    final sessionId = rsp['session_id'] as String?;
    final userId = rsp['user_id'] as String?;

    if (pinTokenBase64 == null || sessionId == null || userId == null) {
      return null;
    }

    final randomPin =
        (Random().nextDouble() * 1000000).round().toString().padLeft(6, '0');

    final iterator = DateTime.now().microsecondsSinceEpoch * 1000;
    final encryptedPin = sdk.encryptPin(
      randomPin,
      pinTokenBase64,
      privateKey,
      iterator,
    );

    final bot0 = sdk.Client(
        userId: userId,
        sessionId: sessionId,
        privateKey: privateKey,
        // scp: authScope,
        interceptors: interceptors,
        httpLogLevel: null);

    await bot0.accountApi.createPin(encryptedPin);

    return KeyStore(
      pin: randomPin,
      clientId: userId,
      sessionId: sessionId,
      pinToken: pinTokenBase64,
      privateKey: privateKey,
    );
  }

  Future<mifiswap.Action?> createSwapAction({
    required String receiverId,
    required String inputAssetId,
    required String outputAssetId,
    required String followId,
    required String amount,
    required String routes,
    required String minReceived,
  }) async {
    final action = mifiswap.ActionProtoSwapCrypto(
      receiverId: receiverId,
      followId: followId,
      fillAssetId: outputAssetId,
      routes: routes,
      minimum: minReceived,
    );
    final rsp = await fswap.createAction(
      action.toString(),
      amount,
      inputAssetId,
    );

    return rsp.data;
  }

  String encryptPin(KeyStore keystore, {int? iterator}) => sdk.encryptPin(
        keystore.pin,
        keystore.pinToken,
        keystore.privateKey,
        iterator ?? DateTime.now().microsecondsSinceEpoch * 1000,
      );

  Future<void> payWithKeyStore({
    required KeyStore keystore,
    required String assetId,
    required String memo,
    required String traceId,
    required String amount,
    int? iterator,
  }) async {
    final encryptedPin = encryptPin(keystore, iterator: iterator);
    final bot = getClientWithKeyStore(keystore);
    await bot.multisigApi.transaction(sdk.RawTransactionRequest(
      assetId: assetId,
      amount: amount,
      opponentMultisig: sdk.OpponentMultisig(
        receivers: [
          'a753e0eb-3010-4c4a-a7b2-a7bda4063f62',
          '099627f8-4031-42e3-a846-006ee598c56e',
          'aefbfd62-727d-4424-89db-ae41f75d2e04',
          'd68ca71f-0e2c-458a-bb9c-1d6c2eed2497',
          'e4bc0740-f8fe-418c-ae1b-32d9926f5863',
        ],
        threshold: 3,
      ),
      pin: encryptedPin,
      traceId: traceId,
      memo: memo,
    ));
  }

  Future<List<sdk.Asset>> getAssetList({KeyStore? keystore}) async {
    final bot0 = getClient(keystore: keystore);
    final rsp = await bot0.assetApi.getAssets();
    final assets = rsp.data;
    final myAssetIdList = [...dbMyAssetIdList];

    for (final asset in assets) {
      myAssetIdList.remove(asset.assetId);
    }

    for (final assetId in myAssetIdList) {
      final rsp = await bot.assetApi.getAssetById(assetId);
      assets.add(rsp.data);
    }

    //.where((swapAsset) => true )// swapAsset.balance.asDecimal > Decimal.zero)
    //.toList();

    return assets;
  }

  Future<Map<String, String>> getBalance({KeyStore? keystore}) async {
    final assets = await getAssetList(keystore: keystore);
    final retval = <String, String>{};
    assets.forEach((v) {
      retval[v.assetId] = v.balance;
    });
    return retval;
  }

  sdk.Client getClient({KeyStore? keystore}) {
    if (keystore == null) {
      return bot;
    }
    return getClientWithKeyStore(keystore);
  }

  sdk.Client getClientWithKeyStore(KeyStore keystore) => sdk.Client(
        userId: keystore.clientId,
        sessionId: keystore.sessionId,
        privateKey: keystore.privateKey,
        interceptors: interceptors,
        httpLogLevel: null,
      );

  Future<void> updateAssets() async {
    final list = await Future.wait([
      client.assetApi.getAssets(),
      client.accountApi.getFiats(),
    ]);
    final assets = (list.first as sdk.MixinResponse<List<sdk.Asset>>).data;
    final fiats = (list.last as sdk.MixinResponse<List<sdk.Fiat>>).data;

    final fixedAssets = <sdk.Asset>[];
    for (final a in assets) {
      if (a.assetId == '47b13785-25e2-3c5c-ac6b-3713e9c31c22') {
        a.name = 'BitTorrent Old';
        // ignore: cascade_invocations
        a.symbol = 'BTTOLD';
      }
      fixedAssets.add(a);
    }
    await mixinDatabase.transaction(() async {
      await mixinDatabase.assetDao.resetAllBalance();
      await mixinDatabase.assetDao.insertAllOnConflictUpdate(fixedAssets);
      await mixinDatabase.fiatDao.insertAllOnConflictUpdate(fiats);
    });

    const presetAssets = {
      xin,
      ethereum,
    };
    // make sure the some asset is in the database
    for (final presetAsset in presetAssets) {
      if (!assets.any((element) => element.assetId == presetAsset)) {
        await updateAsset(presetAsset);
      }
    }
  }

  Future<sdk.Asset> updateAsset(String assetId) async {
    final asset = (await client.assetApi.getAssetById(assetId)).data;
    if (asset.assetId == '47b13785-25e2-3c5c-ac6b-3713e9c31c22') {
      asset.name = 'BitTorrent Old';
      // ignore: cascade_invocations
      asset.symbol = 'BTTOLD';
    }
    await mixinDatabase.assetDao.insert(asset);
    return asset;
  }

  Selectable<AssetResult> assetResults() {
    assert(isLogin);
    return mixinDatabase.assetDao.assetResults(auth!.account.fiatCurrency);
  }

  Selectable<AssetResult> assetResultsNotHidden() {
    assert(isLogin);
    return mixinDatabase.assetDao
        .assetResultsNotHidden(auth!.account.fiatCurrency);
  }

  Selectable<AssetResult> searchAssetResults(String keyword) {
    assert(isLogin);
    return mixinDatabase.assetDao
        .searchAssetResults(auth!.account.fiatCurrency, keyword.trim());
  }

  Selectable<AssetResult> assetResult(String assetId) {
    assert(isLogin);
    return mixinDatabase.assetDao
        .assetResult(auth!.account.fiatCurrency, assetId);
  }

  Selectable<AssetResult> hiddenAssetResult() {
    assert(isLogin);
    return mixinDatabase.assetDao.hiddenAssets(auth!.account.fiatCurrency);
  }

  Future<void> updateAssetHidden(String assetId, {required bool hidden}) {
    assert(isLogin);
    return mixinDatabase.assetsExtraDao.updateHidden(assetId, hidden: hidden);
  }

  Future<Future<void> Function()?> _checkAssetExistWithReturnInsert(
      String assetId) async {
    if (await mixinDatabase.assetDao
            .simpleAssetById(assetId)
            .getSingleOrNull() !=
        null) {
      return null;
    }

    final asset = (await client.assetApi.getAssetById(assetId)).data;
    return () => mixinDatabase.assetDao.insert(asset);
  }

  Future<Future<void> Function()?> _checkUsersExistWithReturnInsert(
      List<String> userIds) async {
    if (userIds.isEmpty) return null;

    final userNeedFetch = userIds.toList();
    final existUsers =
        (await mixinDatabase.userDao.findExistsUsers(userIds).get()).toSet();
    userNeedFetch.removeWhere(existUsers.contains);

    if (userNeedFetch.isEmpty) return null;

    final users = await client.userApi.getUsers(userNeedFetch);

    return () => mixinDatabase.userDao
        .insertAll(users.data.map((user) => user.toDbUser()).toList());
  }

  Future<List<sdk.Snapshot>> updateAssetSnapshots(
    String assetId, {
    String? offset,
    int limit = 30,
  }) async {
    final result = await Future.wait([
      client.snapshotApi.getSnapshots(
        assetId: assetId,
        offset: offset,
        limit: limit,
      ),
      _checkAssetExistWithReturnInsert(assetId),
    ]);
    final response = result[0]! as sdk.MixinResponse<List<sdk.Snapshot>>;
    final insertAsset = result[1] as Future<void> Function()?;

    final insertUsers = await _checkUsersExistWithReturnInsert(
        response.data.map((e) => e.opponentId).whereNotNull().toList());

    await mixinDatabase.transaction(() async {
      await Future.wait([
        mixinDatabase.snapshotDao.insertAll(response.data),
        insertUsers?.call(),
        insertAsset?.call(),
      ].where((element) => element != null).cast<Future<void>>());
    });
    return response.data;
  }

  Future<List<SnapshotItem>> getSnapshots({
    required String assetId,
    String? offset,
    int limit = 30,
    String? opponent,
    String? destination,
    String? tag,
  }) async {
    final result = await Future.wait([
      client.snapshotApi.getSnapshots(
        assetId: assetId,
        offset: offset,
        limit: limit,
        opponent: opponent,
        destination: destination,
        tag: tag,
      ),
      _checkAssetExistWithReturnInsert(assetId),
    ]);
    final response = result[0]! as sdk.MixinResponse<List<sdk.Snapshot>>;
    final insertAsset = result[1] as Future<void> Function()?;

    final insertUsers = await _checkUsersExistWithReturnInsert(
        response.data.map((e) => e.opponentId).whereNotNull().toList());
    return mixinDatabase.transaction(() async {
      await Future.wait([
        mixinDatabase.snapshotDao.insertAll(response.data),
        insertUsers?.call(),
        insertAsset?.call(),
      ].where((element) => element != null).cast<Future<void>>());
      return mixinDatabase.snapshotDao
          .snapshotsByIds(response.data.map((e) => e.snapshotId).toList())
          .get();
    });
  }

  Future<List<sdk.Snapshot>> updateAllSnapshots({
    String? offset,
    String? opponent,
    int limit = 30,
  }) async {
    final snapshots = await client.snapshotApi
        .getSnapshots(offset: offset, limit: limit, opponent: opponent)
        .then((value) => value.data);

    final closures = [
      await _checkUsersExistWithReturnInsert(
          snapshots.map((e) => e.opponentId).toSet().whereNotNull().toList()),
      for (final assetId in snapshots.map((e) => e.assetId).toSet())
        await _checkAssetExistWithReturnInsert(assetId)
    ];

    await mixinDatabase.transaction(() async {
      await Future.wait([
        mixinDatabase.snapshotDao.insertAll(snapshots),
        ...closures.map((e) => e?.call())
      ].whereNotNull());
    });
    return snapshots;
  }

  Future<void> updateSnapshotById({required String snapshotId}) async {
    final data = await client.snapshotApi.getSnapshotById(snapshotId);

    final closures = await Future.wait([
      _checkUsersExistWithReturnInsert(
        [data.data.opponentId].whereNotNull().toList(),
      ),
      _checkAssetExistWithReturnInsert(data.data.assetId),
    ]);

    await mixinDatabase.transaction(() async {
      await Future.wait([
        mixinDatabase.snapshotDao.insertAll([data.data]),
        ...closures.map((e) => e?.call()),
      ].where((element) => element != null).cast<Future<void>>());
    });
  }

  Future<bool> updateSnapshotByTraceId({required String traceId}) async {
    try {
      final data = await client.snapshotApi.getSnapshotByTraceId(traceId);
      final closures = await Future.wait([
        _checkUsersExistWithReturnInsert(
          [data.data.opponentId].whereNotNull().toList(),
        ),
        _checkAssetExistWithReturnInsert(data.data.assetId),
      ]);
      await mixinDatabase.transaction(() async {
        await Future.wait([
          mixinDatabase.snapshotDao.insertAll([data.data]),
          ...closures.map((e) => e?.call()),
        ].whereNotNull().cast<Future<void>>());
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> refreshPendingDeposits(AssetResult asset) =>
      _refreshPendingDeposits(asset.assetId, asset.getDestination(), asset.tag);

  Future<void> _refreshPendingDeposits(
    String assetId,
    String? assetDestination,
    String? assetTag,
  ) async {
    if (assetDestination?.isNotEmpty ?? false) {
      final ret = await client.assetApi.pendingDeposits(
        assetId,
        destination: assetDestination,
        tag: assetTag,
      );
      await mixinDatabase.snapshotDao.clearPendingDepositsByAssetId(assetId);
      if (ret.data.isEmpty) {
        return;
      }
      await _processPendingDeposit(assetId, ret.data);
    } else {
      final asset = await updateAsset(assetId);
      assert(asset.getDestination() != null);
      await _refreshPendingDeposits(
          asset.assetId, asset.getDestination(), asset.tag);
    }
  }

  Future<void> _processPendingDeposit(
      String assetId, List<sdk.PendingDeposit> pendingDeposits) async {
    final hashList = pendingDeposits.map((e) => e.transactionHash).toList();
    final existHashSets = (await mixinDatabase.snapshotDao
            .snapshotIdsByTransactionHashList(assetId, hashList)
            .get())
        .toSet();
    final snapshots = pendingDeposits
        .where((e) => !existHashSets.contains(e.transactionHash))
        .map((e) => e.toSnapshot(assetId))
        .toList();
    await mixinDatabase.snapshotDao.insertPendingDeposit(snapshots);
  }

  Selectable<Addresse> addresses(String assetId) {
    assert(isLogin);
    return mixinDatabase.addressDao.addressesByAssetId(assetId);
  }

  Future<List<sdk.Address>> updateAddresses(String assetId) async {
    final addresses =
        (await client.addressApi.getAddressesByAssetId(assetId)).data;
    await mixinDatabase.addressDao.insertAllOnConflictUpdate(addresses);
    return addresses;
  }

  Selectable<User> friends() => mixinDatabase.findFriendsNotBot();

  Future<void> updateFriends() async {
    assert(isLogin);
    try {
      final friends = await client.accountApi.getFriends();
      await mixinDatabase.userDao
          .insertAll(friends.data.map((e) => e.toDbUser()).toList());
    } on DioError catch (e) {
      if (e.optionMixinError?.isForbidden ?? false) {
        rethrow;
      }
      d('update friends failed: $e');
    } catch (e) {
      d('update friends failed: $e');
    }
  }

  Future<List<User>> loadUsersIfNotExist(List<String> ids) async {
    if (ids.isEmpty) {
      return const [];
    }
    final cb = await _checkUsersExistWithReturnInsert(ids);
    await cb?.call();
    final list = await mixinDatabase.userDao.userByIds(ids).get();
    assert(list.length == ids.length,
        'count not match ${list.length} ${ids.length}');
    return list;
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    final mixinDatabase0 = _mixinDatabase;
    _mixinDatabase = null;
    await mixinDatabase0?.close();
    timer.cancel();
  }

  @override
  List<Object?> get props => [
        bot,
        fswap,
        _mixinDatabase,
      ];

  Future<void> searchAndUpdateAsset(String keyword) async {
    if (keyword.isEmpty) return;
    final mixinResponse = await client.assetApi.queryAsset(keyword);
    final fixedAssets = <sdk.Asset>[];
    for (final a in mixinResponse.data) {
      if (a.assetId == '47b13785-25e2-3c5c-ac6b-3713e9c31c22') {
        a.name = 'BitTorrent Old';
        // ignore: cascade_invocations
        a.symbol = 'BTTOLD';
      }
      fixedAssets.add(a);
    }
    await mixinDatabase.assetDao
        .insertAllOnConflictUpdateWithoutBalance(fixedAssets);
  }

  Future<void> updateTopAssetIds() async {
    final list = (await client.assetApi.getTopAssets()).data;
    // todo update, now balance always 0
    // unawaited(mixinDatabase.assetDao.insertAllOnConflictUpdate(list));
    final assetIds = list.map((e) => e.assetId).toList();
    replaceTopAssetIds(assetIds);
  }

  Stream<List<AssetResult>> watchAssetResultsOfIn(Iterable<String> assetIds) =>
      mixinDatabase.assetDao
          .assetResultsOfIn(auth!.account.fiatCurrency, assetIds)
          .watch()
          .map((list) {
        final map = Map.fromEntries(list.map((e) => MapEntry(e.assetId, e)));
        return assetIds
            .map(map.remove)
            .where((element) => element != null)
            .cast<AssetResult>()
            .toList();
      });

  Future<List<AssetResult>> findOrSyncAssets(List<String> assetIds) =>
      Future.wait(assetIds.map(findOrSyncAsset)).then(
          (list) => list.where((e) => e != null).cast<AssetResult>().toList());

  Future<AssetResult?> findOrSyncAsset(String assetId) async {
    assert(isLogin);
    final result = await mixinDatabase.assetDao
        .assetResult(auth!.account.fiatCurrency, assetId)
        .getSingleOrNull();
    if (result != null) return result;

    final asset = (await client.assetApi.getAssetById(assetId)).data;
    await mixinDatabase.assetDao.insert(asset);
    return mixinDatabase.assetDao
        .assetResult(auth!.account.fiatCurrency, assetId)
        .getSingleOrNull();
  }

  Future<List<sdk.CollectibleOutput>> _loadUnspentTransactionOutputs({
    String? offset,
  }) async {
    // hash member id.
    final members = auth!.account.userId;

    String hashMemberId(String member) {
      try {
        final bytes =
            SHA3Digest(256).process(Uint8List.fromList(utf8.encode(member)));
        return hex.encode(bytes);
      } catch (e, s) {
        d('updateCollectibles error: $e, $s');
        return '';
      }
    }

    const threshold = 1;
    const limit = 500;

    final response = await client.collectibleApi.getOutputs(
      members: hashMemberId(members),
      limit: limit,
      threshold: threshold,
      offset: offset,
    );

    final outputs = <sdk.CollectibleOutput>[];
    for (final output in response.data) {
      final receivers = List<String>.from(output.receivers)..sort();
      if (receivers.join() != members) {
        d('receivers not match: outputId ${output.outputId}');
        continue;
      }
      if (output.receiversThreshold != threshold) {
        d('threshold not match: ${output.outputId}');
        continue;
      }
      if (output.state == sdk.CollectibleOutput.kStateSpent) {
        d('state not match: ${output.outputId}');
        continue;
      }
      outputs.add(output);
    }

    if (response.data.length == limit) {
      outputs.addAll(await _loadUnspentTransactionOutputs(
        offset: response.data.last.createdAt,
      ));
    }
    return outputs;
  }

  Future<void> updateCollectibles() async {
    try {
      final utxos = await _loadUnspentTransactionOutputs();
      final tokenIds = utxos.map((e) => e.tokenId).toList();
      await mixinDatabase.collectibleDao.updateOutputs(utxos);
      mixinDatabase.collectibleDao.removeNotExist(tokenIds);
      await refreshCollectiblesTokenIfNotExist(tokenIds);
    } on DioError catch (e, s) {
      if (e.optionMixinError?.isForbidden ?? false) {
        rethrow;
      }
      d('updateCollectibles error: $e, $s');
    } catch (e, s) {
      d('updateCollectibles error: $e, $s');
    }
  }

  Future<void> refreshCollectiblesTokenIfNotExist(List<String> tokenIds) async {
    final toRefresh =
        await mixinDatabase.collectibleDao.filterExistsTokens(tokenIds);

    final collectionIds = <String>{};
    for (final tokenId in toRefresh) {
      try {
        final response = await client.collectibleApi.getToken(tokenId);
        final token = response.data;
        collectionIds.add(token.collectionId);
        await mixinDatabase.collectibleDao.insertCollectible(token);
      } catch (error, stacktrace) {
        d('refreshTokenIfNotExist error:$tokenId $error $stacktrace');
      }
    }
    await refreshCollection(collectionIds.toList(), force: false);
  }

  Future<void> refreshCollection(
    List<String> collectionIds, {
    bool force = false,
  }) async {
    final toRefresh = force
        ? collectionIds
        : await mixinDatabase.collectibleDao
            .filterExistsCollections(collectionIds);
    for (final collectionId in toRefresh) {
      if (collectionId.isEmpty) {
        // Ignore empty collectionId;
        continue;
      }
      try {
        final response = await client.collectibleApi.collections(collectionId);
        final collection = response.data;
        await mixinDatabase.collectibleDao.insertCollection(collection);
      } catch (error, stacktrace) {
        d('refreshCollection error:$collectionId $error $stacktrace');
      }
    }
  }

  Stream<List<MapEntry<String, List<CollectibleItem>>>> groupedCollectibles() =>
      mixinDatabase.collectibleDao.getAllCollectibles().watch().map((event) {
        final grouped = event.groupListsBy((e) => e.collectionId);
        final result = <MapEntry<String, List<CollectibleItem>>>[];
        grouped.forEach((key, value) {
          if (key.isEmpty) {
            for (final item in value) {
              result.add(MapEntry(key, [item]));
            }
          } else {
            result.add(MapEntry(key, value));
          }
        });
        return result;
      });

  Stream<Collection?> collection(String collectionId) =>
      mixinDatabase.collectibleDao.collection(collectionId).watchSingleOrNull();

  Future<int> getPinErrorRemainCount() async {
    const pinErrorMax = 5;
    try {
      final response = await client.accountApi.pinLogs(
        category: 'PIN_INCORRECT',
        limit: pinErrorMax,
      );

      final count = response.data.fold<int>(0, (previousValue, element) {
        final onDayAgo = DateTime.now().subtract(const Duration(days: 1));
        if (DateTime.parse(element.createdAt).isAfter(onDayAgo)) {
          return previousValue + 1;
        }
        return previousValue;
      });

      return pinErrorMax - count;
    } catch (error, stacktrace) {
      e('getPinErrorCount error: $error, $stacktrace');
      return pinErrorMax;
    }
  }
}
