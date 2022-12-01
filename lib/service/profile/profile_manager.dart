import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:hive_flutter/hive_flutter.dart';

import '../../mixin_wallet/service/profile/auth.dart';
import '../../mixin_wallet/service/profile/profile_manager.dart';

// import '../../util/web/web_utils_dummy.dart'
//     if (dart.library.html) '../../util/web/web_utils.dart';
import 'keystore.dart';

export '../../mixin_wallet/service/profile/profile_manager.dart';

// Auth? get auth => profileBox.get('auth') as Auth?;
//
// Future<void> setAuth(Auth? value) => profileBox.put('auth', value);

Auth? get mixinAuth => profileBox.get('mixin_auth') as Auth?;

Future<void> setMixinAuth(Auth? value) => profileBox.put('mixin_auth', value);

// Box<dynamic> get profileBox => Hive.box('profile');
//
// String? get accessToken => auth?.accessToken;

// bool get isLogin => accessToken != null;
// bool get useFennec => accessToken == 'fennec';
// bool get useMixinMessager => !useFennec;

// class _AuthAdapter extends TypeAdapter<Auth> {
//   @override
//   Auth read(BinaryReader reader) => Auth.fromJson(reader
//       .readMap()
//       .map((key, value) => MapEntry<String, dynamic>(key as String, value)));
//
//   @override
//   int get typeId => 0;
//
//   @override
//   void write(BinaryWriter writer, Auth obj) {
//     writer.writeMap(obj.toJson());
//   }
// }

bool get _isAuthChange {
  final ret = profileBox.get('isAuthChange');
  return (ret is bool ? ret : null) ?? false;
}

set _isAuthChange(bool value) => profileBox.put('isAuthChange', value);

final ValueNotifier<bool> isAuthChange = () {
  final notifier = ValueNotifier(_isAuthChange);
  notifier.addListener(() {
    _isAuthChange = notifier.value;
  });
  return notifier;
}();

String? get dbInputAssetId => profileBox.get('inputAssetId') as String?;

Future<void> setDbInputAssetId(String? value) =>
    profileBox.put('inputAssetId', value);

String? get dbOutputAssetId => profileBox.get('outputAssetId') as String?;

Future<void> setDbOutputAssetId(String? value) =>
    profileBox.put('outputAssetId', value);

IOSOptions getIOSOptions() => const IOSOptions(
      accountName: 'fennec',
      accessibility: KeychainAccessibility.first_unlock,
    );

AndroidOptions getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
      // sharedPreferencesName: 'Test2',
      // preferencesKeyPrefix: 'Test'
    );

FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

Future<KeyStore?> getKeyStore() async {
  final value = await secureStorage.read(
    key: 'keystore',
    iOptions: getIOSOptions(),
    aOptions: getAndroidOptions(),
  );
  if (value == null) {
    return null;
  }
  final data = jsonDecode(value) as Map<String, dynamic>;
  return KeyStore.fromJson(data);
}

Future<void> setKeyStore(KeyStore? value) async {
  await secureStorage.write(
    key: 'keystore',
    value: jsonEncode(value),
    iOptions: getIOSOptions(),
    aOptions: getAndroidOptions(),
  );
}

List<String> getMyAssetIdList() {
  final str = profileBox.get('my_swapAsset_id_list') as String? ?? '';

  if (str.isEmpty) {
    return <String>[];
  }
  return str.split(',');
}

List<String> get dbMyAssetIdList => getMyAssetIdList();

Future<void> setDbMyAssetIdList(List<String> value) =>
    profileBox.put('my_swapAsset_id_list', value.join(','));
