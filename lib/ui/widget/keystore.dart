// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// import '../../service/profile/keystore.dart';
import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
// import '../../util/hook.dart';
import '../../util/r.dart';
import 'dialog_builder.dart';

class KeyStoreWidget extends HookWidget {
  const KeyStoreWidget({Key? key, this.autoPop = false}) : super(key: key);

  final bool autoPop;

  @override
  Widget build(BuildContext context) {
    // final keyStoreController = useTextEditingController();
    final fullNameController = useTextEditingController();

    // useMemoizedFuture<void>(() async {
    //   final keystore = await getKeyStore();
    //   if (keystore != null) {
    //     keyStoreController.text = jsonEncode(keystore);
    //   }
    // });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fennec'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
           ListTile(
            title: Text(context.l10n.createAccount),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: fullNameController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Full Name'),
            ),
          ),
          ListTile(
            title: ElevatedButton.icon(
              icon: Image.asset(
                R.resourcesFennecLogoPng,
                width: 24,
                height: 24,
              ),
              label:  Text( context.l10n.createAccount),
              onPressed: () async {
                if (fullNameController.text.isEmpty) {
                  DialogBuilder(context).showError('请输入钱包名称');
                  return;
                }
                await DialogBuilder(context).process(() async {
                  final ks = await context.appServices
                      .createKeyStore(fullNameController.text);
                  if (ks == null) {
                    await setKeyStore(ks);
                    await context.appServices.loginWithKeyStore(ks!);
                    isAuthChange.value = !isAuthChange.value;
                    if (autoPop) {
                      Navigator.of(context).pop();
                    }
                  } else {
                    DialogBuilder(context).showError('创建失败');
                  }
                });
              },
            ),
          ),
          const Divider(thickness: 10),
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
