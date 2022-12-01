import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../service/profile/keystore.dart';
import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/r.dart';
import 'dialog_builder.dart';

class ImportKeyStoreWidget extends HookWidget {
  const ImportKeyStoreWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keyStoreController = useTextEditingController();
    // final fullNameController = useTextEditingController();

    useMemoizedFuture<void>(() async {
      final keystore = await getKeyStore();
      if (keystore != null) {
        keyStoreController.text = jsonEncode(keystore);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fennec账户'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          const ListTile(
            title: Text('已有账户'),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 3,
              controller: keyStoreController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: 'KeyStore'),
            ),
          ),
          ListTile(
            title: ElevatedButton.icon(
              icon: Image.asset(
                R.resourcesFennecLogoPng,
                width: 24,
                height: 24,
              ),
              label: const Text('导入账户'),
              onPressed: () async {
                if (keyStoreController.text.isEmpty) {
                  DialogBuilder(context).showError('请输入账户的KeyStore');
                  return;
                }
                try {
                  final json = jsonDecode(keyStoreController.text)
                      as Map<String, dynamic>;
                  final store = KeyStore.fromJson(json);
                  await setKeyStore(store);
                  await DialogBuilder(context).process(() async {
                    await context.appServices.loginWithKeyStore(store);
                  }, text: '正在登录中......');
                  isAuthChange.value = !isAuthChange.value;
                  Navigator.of(context).pop();
                } catch (e) {
                  DialogBuilder(context).showError('请输入正确的KeyStore信息 $e');
                }
              },
            ),
          ),
          ListTile(
            title: Text(context.l10n.connectinfo +
                context.l10n.termsOfService +
                context.l10n.and +
                context.l10n.privaryPolicy),
          ),
        ],
      ),
    );
  }
}
