import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// import './auth.dart';
// import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
// import '../../util/r.dart';
// import '../widget/action_button.dart';
// import '../widget/avatar.dart';
// import '../widget/menu.dart';
import '../widget/mixin_appbar.dart';
// import '../widget/mixin_bottom_sheet.dart';

class TopAppBar extends HookWidget implements PreferredSizeWidget {
  const TopAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      // final authChange = useValueListenable(isAuthChange);
      // final account = useMemoized(() => auth?.account, [authChange]);
      MixinAppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          // child: Center(
          //   child: InkResponse(
          //     radius: 24,
          //     onTap: () => showMixinBottomSheet<void>(
          //       context: context,
          //       builder: (context) => const _AccountBottomSheet(),
          //     ),
          //     child: account == null
          //         ? const SizedBox()
          //         : Avatar(
          //             avatarUrl: account.avatarUrl,
          //             userId: account.userId,
          //             name: account.fullName ?? '',
          //             size: 32,
          //           ),
          //   ),
          // ),
        ),
        // actions: [
        //   ActionButton(
        //     name: R.resourcesSettingSvg,
        //     size: 24,
        //     onTap: () => showMixinBottomSheet<void>(
        //       context: context,
        //       builder: (context) => const _SettingBottomSheet(),
        //     ),
        //   )
        // ],
        backgroundColor: context.colorScheme.background,
      );

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

// //ok
// class _AccountBottomSheet extends StatelessWidget {
//   const _AccountBottomSheet({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final account = auth?.account;
//     // might be null when use clicked DeAuthorize button.
//     if (account == null) {
//       return const SizedBox();
//     }
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         MixinBottomSheetTitle(
//             title: Row(
//           children: [
//             Avatar(
//               avatarUrl: account.avatarUrl,
//               userId: account.userId,
//               name: account.fullName ?? '',
//               size: 32,
//             ),
//             const SizedBox(width: 16),
//             Text(
//               account.fullName ?? '',
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black,
//               ),
//             ),
//           ],
//         )),
//         const SizedBox(height: 8),
//         MenuItemWidget(
//           topRounded: true,
//           bottomRounded: true,
//           title: Text(
//             context.l10n.walletlogout,
//             style: TextStyle(
//               color: context.colorScheme.red,
//             ),
//           ),
//           onTap: () async {
//             // final id = auth!.account.identityNumber;
//             // await profileBox.clear();
//             await setAuth(null);
//             isAuthChange.value = !isAuthChange.value;
//             // await deleteDatabase(id);
//             // context.replace(authUri.path);
//             Navigator.pop(context);
//           },
//         ),
//         const SizedBox(height: 100),
//       ],
//     );
//   }
// }
// //no
// class _SettingBottomSheet extends StatelessWidget {
//   const _SettingBottomSheet({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final account = (mixinAuth ?? auth)?.account;
//     // might be null when use clicked DeAuthorize button.
//     if (account == null) {
//       return const SizedBox();
//     }
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         MixinBottomSheetTitle(
//           title: Text(
//             context.l10n.setting, // header title
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: Colors.black,
//             ),
//           ),
//         ),
//         MenuItemWidget(
//           topRounded: true,
//           bottomRounded: true,
//           title: Row(
//             children: [
//               Avatar(
//                 avatarUrl: account.avatarUrl,
//                 userId: account.userId,
//                 name: account.fullName ?? '',
//                 size: 32,
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 account.fullName ?? '',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         if (mixinAuth != null)
//           MenuItemWidget(
//             topRounded: true,
//             bottomRounded: true,
//             title: Text(
//               '解绑Mixin',
//               style: TextStyle(
//                 color: context.colorScheme.red,
//               ),
//             ),
//             onTap: () async {
//               await setMixinAuth(null);
//               Navigator.pop(context);
//             },
//           )
//         else
//           MenuItemWidget(
//             topRounded: true,
//             bottomRounded: true,
//             title: Text(
//               '绑定Mixin',
//               style: TextStyle(
//                 color: context.colorScheme.red,
//               ),
//             ),
//             onTap: () async {
//               await Navigator.of(context).push(
//                 MaterialPageRoute<void>(
//                   builder: (context) => const Auth(bind: true),
//                 ),
//               );
//               // await setMixinAuth(null);
//               Navigator.pop(context);
//             },
//           ),
//         const SizedBox(height: 100),
//         MenuItemWidget(
//           topRounded: true,
//           bottomRounded: true,
//           title: Text(
//             context.l10n.walletlogout,
//             style: TextStyle(
//               color: context.colorScheme.red,
//             ),
//           ),
//           onTap: () async {
//             // final id = auth!.account.identityNumber;
//             // await profileBox.clear();
//             await setAuth(null);
//             isAuthChange.value = !isAuthChange.value;
//             // await deleteDatabase(id);
//             // context.replace(authUri.path);
//             Navigator.pop(context);
//           },
//         ),
//       ],
//     );
//   }
// }
