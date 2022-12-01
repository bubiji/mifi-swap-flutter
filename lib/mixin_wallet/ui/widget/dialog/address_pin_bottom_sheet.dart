import 'package:flutter/material.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../../../../db/mixin_database.dart';
import '../../../../service/profile/profile_manager.dart';
import '../../../../util/extension/extension.dart';

Future<bool> showDeleteAddressByPinBottomSheet(
  BuildContext context, {
  required Addresse address,
}) async {
  final keystore = await getKeyStore();
  if (keystore == null) {
    return false;
  }
  final api = context.appServices.client.addressApi;
  await api.deleteAddressById(
      address.addressId, context.appServices.encryptPin(keystore));
  return true;
}

Future<bool> showAddAddressByPinBottomSheet(
  BuildContext context, {
  required String assetId,
  required String destination,
  required String label,
  required String? tag,
}) async {
  final keystore = await getKeyStore();
  if (keystore == null) {
    return false;
  }
  final api = context.appServices.client.addressApi;
  final response = await api.addAddress(sdk.AddressRequest(
    assetId: assetId,
    pin: context.appServices.encryptPin(keystore),
    destination: destination,
    tag: tag,
    label: label,
  ));
  await context.mixinDatabase.addressDao
      .insertAllOnConflictUpdate([response.data]);

  return true;
}
