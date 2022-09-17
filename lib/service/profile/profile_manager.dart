import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../util/web/web_utils_dummy.dart'
    if (dart.library.html) '../../util/web/web_utils.dart';
import 'auth.dart';

Future<void> initStorage() async {
  Hive.registerAdapter(_AuthAdapter());
  await Hive.initFlutter();
  fixSafariIndexDb();
  await Hive.openBox<dynamic>('profile');
}

Auth? get auth => profileBox.get('auth') as Auth?;

Future<void> setAuth(Auth? value) => profileBox.put('auth', value);

Box<dynamic> get profileBox => Hive.box('profile');

String? get accessToken => auth?.accessToken;

bool get isLogin => accessToken != null;

class _AuthAdapter extends TypeAdapter<Auth> {
  @override
  Auth read(BinaryReader reader) => Auth.fromJson(reader
      .readMap()
      .map((key, value) => MapEntry<String, dynamic>(key as String, value)));

  @override
  int get typeId => 0;

  @override
  void write(BinaryWriter writer, Auth obj) {
    writer.writeMap(obj.toJson());
  }
}

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
