// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keystore.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeyStore _$KeyStoreFromJson(Map json) => KeyStore(
      pin: json['pin'] as String,
      clientId: json['client_id'] as String,
      sessionId: json['session_id'] as String,
      pinToken: json['pin_token'] as String,
      privateKey: json['private_key'] as String,
    );

Map<String, dynamic> _$KeyStoreToJson(KeyStore instance) => <String, dynamic>{
      'pin': instance.pin,
      'client_id': instance.clientId,
      'session_id': instance.sessionId,
      'pin_token': instance.pinToken,
      'private_key': instance.privateKey,
    };
