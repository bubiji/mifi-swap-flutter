import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'keystore.g.dart';

@JsonSerializable(anyMap: true)
class KeyStore extends Equatable {
  const KeyStore({
    required this.pin,
    required this.clientId,
    required this.sessionId,
    required this.pinToken,
    required this.privateKey,
  });

  factory KeyStore.fromJson(Map<String, dynamic> json) =>
      _$KeyStoreFromJson(json);

  Map<String, dynamic> toJson() => _$KeyStoreToJson(this);

  @JsonKey(name: 'pin')
  final String pin;
  @JsonKey(name: 'client_id')
  final String clientId;
  @JsonKey(name: 'session_id')
  final String sessionId;
  @JsonKey(name: 'pin_token')
  final String pinToken;
  @JsonKey(name: 'private_key')
  final String privateKey;

  @override
  List<Object?> get props => [pin, clientId, sessionId, pinToken, privateKey];

  KeyStore copyWith({
    String? pin,
    String? clientId,
    String? sessionId,
    String? pinToken,
    String? privateKey,
  }) =>
      KeyStore(
        pin: pin ?? this.pin,
        clientId: clientId ?? this.clientId,
        sessionId: sessionId ?? this.sessionId,
        pinToken: pinToken ?? this.pinToken,
        privateKey: privateKey ?? this.privateKey,
      );
}
