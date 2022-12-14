import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:hive/hive.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../../../util/logger.dart';
import '../../util/crypto_util.dart';

final _sessionBox = Hive.box('session');

class Session {
  Session._();

  static Session? _instance;

  static Session get instance => _instance ??= Session._();

  static const _keyPinToken = 'pinToken';
  static const _keyPinIterator = 'pinIterator';

  String? get pinToken =>
      _sessionBox.get(_keyPinToken, defaultValue: null) as String?;

  set pinToken(String? value) => _sessionBox.put(_keyPinToken, value);

  int get pinIterator =>
      _sessionBox.get(_keyPinIterator, defaultValue: 1) as int;

  set pinIterator(int value) => _sessionBox.put(_keyPinIterator, value);

  bool checkPinToken() => pinToken != null && pinToken!.isNotEmpty;
}

List<int> decryptPinToken(String serverPublicKey, List<int> privateKey) {
  final bytes = base64Decode(serverPublicKey);
  final private = sdk.privateKeyToCurve25519(Uint8List.fromList(privateKey));
  return calculateAgreement(bytes, private);
}

String? encryptPin(String code) {
  assert(code.isNotEmpty, 'code is empty');
  final iterator = DateTime.now().millisecondsSinceEpoch * 1000000;
  final pinToken = Session.instance.pinToken;

  if (pinToken == null) {
    e('pinToken is null');
    return null;
  }

  d('pinToken: $pinToken');

  final pinBytes = Uint8List.fromList(utf8.encode(code));
  final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final timeBytes = Int64(nowSec).toBytes();
  final iteratorBytes = Int64(iterator).toBytes();

  // pin+time+iterator
  final plaintext = Uint8List.fromList(pinBytes + timeBytes + iteratorBytes);
  final ciphertext = aesEncrypt(base64Decode(pinToken), plaintext);

  Session.instance.pinIterator = iterator + 1;

  return base64Encode(ciphertext);
}
