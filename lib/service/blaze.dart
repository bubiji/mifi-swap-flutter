import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MixinClient {
  MixinClient();

  WebSocketChannel? channel;
  Uuid uuid = const Uuid();
  bool handled = false;
  Timer? timer;

  void connect(
      String clientId, String scope, bool Function(String?, String?) callback) {
    // print('wss connect');
    channel = WebSocketChannel.connect(
      Uri.parse('wss://blaze.mixin.one'),
      protocols: ['Mixin-OAuth-1'],
    );
    handled = false;

    channel?.stream.listen((message) {
      if (handled) {
        return;
      }
      final msg = parseBlazeMessage(message as List<int>);
      // print('wss connected');
      // print(msg);
      // channel.sink.add('received!');
      // channel.sink.close(status.goingAway);
      timer?.cancel();

      final data = msg['data'] as Map<String, dynamic>;

      final codeId = data['code_id'] as String;

      final url = 'mixin://codes/$codeId';
      callback(url, null);

      final code = data['authorization_code'] as String?;
      if ((code?.length ?? 0) > 16) {
        if (callback(null, code)) {
          handled = true;
        }
        return;
      }

      final authId = data['authorization_id'] as String?;
      timer = Timer(const Duration(seconds: 1),
          () => sendRefreshCode(clientId, scope, authId));
    });

    timer = Timer(const Duration(seconds: 1),
        () => sendRefreshCode(clientId, scope, null));
  }

  void sendGZip(Map<String, dynamic> msg) {
    channel?.sink.add(gzipBlazeMessage(msg));
  }

  void sendRefreshCode(String clientId, String scope, String? authorization) {
    if (handled) {
      return;
    }

    final id = uuid.v4();
    final data = <String, dynamic>{
      'id': id,
      'action': 'REFRESH_OAUTH_CODE',
      'params': {
        'client_id': clientId,
        'scope': scope,
        // "code_challenge": codeChallenge,
        'authorization_id': authorization ?? '',
      },
    };

    sendGZip(data);
  }
}

Map<String, dynamic> parseBlazeMessage(List<int> message) {
  final content = String.fromCharCodes(GZipDecoder().decodeBytes(message));
  return jsonDecode(content) as Map<String, dynamic>;
}

List<int>? gzipBlazeMessage(Map<String, dynamic> msg) =>
    GZipEncoder().encode(Uint8List.fromList((jsonEncode(msg)).codeUnits));
