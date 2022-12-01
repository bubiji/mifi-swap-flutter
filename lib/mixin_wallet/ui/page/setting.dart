import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../generated/r.dart';
import '../../../service/profile/profile_manager.dart';
import '../../../ui/widget/auth.dart';
// import '../../../ui/widget/import_keystore.dart';
import '../../../util/extension/extension.dart';
// import '../../service/profile/profile_manager.dart';
// import '../router/mixin_routes.dart';
import '../router/mixin_routes.dart';
import '../widget/buttons.dart';
import '../widget/menu.dart';
import '../widget/mixin_appbar.dart';

class Setting extends StatelessWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MixinAppBar(
          leading: const MixinBackButton2(),
          title: SelectableText(
            context.l10n.settings,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
            ),
            enableInteractiveSelection: false,
          ),
          backgroundColor: context.colorScheme.background,
        ),
        backgroundColor: context.colorScheme.background,
        body: const _SettingsBody(),
      );
}

class _SettingsBody extends HookWidget {
  const _SettingsBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hideSmallAssets = useValueListenable(isSmallAssetsHidden);

    return Column(
      children: [
        const SizedBox(height: 24),
        MenuItemWidget(
          topRounded: true,
          leading: SvgPicture.asset(R.resourcesAllTransactionsSvg),
          title: Text(context.l10n.allTransactions),
          onTap: () => context.push(transactionsUri),
        ),
        MenuItemWidget(
          bottomRounded: true,
          leading: SvgPicture.asset(R.resourcesHiddenSvg),
          title: Text(context.l10n.hiddenAssets),
          onTap: () => context.push(hiddenAssetsUri),
        ),
        const SizedBox(height: 10),
        MenuItemWidget(
          topRounded: true,
          bottomRounded: true,
          title: Text(context.l10n.hideSmallAssets),
          leading: SvgPicture.asset(R.resourcesHideAssetsSvg),
          trailing: Switch(
            value: hideSmallAssets,
            activeColor: const Color(0xff333333),
            onChanged: (bool value) => isSmallAssetsHidden.value = value,
          ),
        ),
        const SizedBox(height: 10),
        // mixin 绑定解绑
        if (mixinAuth != null)
          MenuItemWidget(
            topRounded: true,
            bottomRounded: true,
            title: Text(
              '解绑Mixin',
              style: TextStyle(
                color: context.colorScheme.red,
              ),
            ),
            onTap: () async {
              await setMixinAuth(null);
              Navigator.pop(context);
            },
          )
        else
          MenuItemWidget(
            topRounded: true,
            bottomRounded: true,
            title: Text(
              '绑定Mixin',
              style: TextStyle(
                color: context.colorScheme.red,
              ),
            ),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const Auth(bind: true),
                ),
              );
              // await setMixinAuth(null);
            },
          ),
        const SizedBox(height: 8),
        // import keystore
        // MenuItemWidget(
        //   topRounded: true,
        //   bottomRounded: true,
        //   title: Text(
        //     context.l10n.walletImport,
        //     style: TextStyle(
        //       color: context.colorScheme.red,
        //     ),
        //   ),
        //   onTap: () async {
        //     await Navigator.of(context).push(
        //       MaterialPageRoute<void>(
        //         builder: (context) => const ImportKeyStoreWidget(),
        //       ),
        //     );
        //     // await setMixinAuth(null);
        //   },
        // ),
        // const SizedBox(height: 8),
        //logout
        // MenuItemWidget(
        //   topRounded: true,
        //   bottomRounded: true,
        //   title: Text(
        //     context.l10n.walletlogout,
        //     style: TextStyle(
        //       color: context.colorScheme.red,
        //     ),
        //   ),
        //   onTap: () async {
        //     // final id = auth!.account.identityNumber;
        //     // await profileBox.clear();
        //     await setAuth(null);
        //     isAuthChange.value = !isAuthChange.value;
        //     // await deleteDatabase(id);
        //     // context.replace(authUri.path);
        //     Navigator.pop(context);
        //   },
        // ),
      ],
    );
  }
}
