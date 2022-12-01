// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
// import 'package:vrouter/vrouter.dart';

import '../../mixin_wallet/ui/page/home.dart';
import '../../service/profile/profile_manager.dart';
// import '../../util/extension/extension.dart';
// import '../../util/hook.dart';
// import '../../util/logger.dart';
// import '../widget/account.dart';
// import '../widget/dialog_builder.dart';
// import '../widget/symbol.dart';
import '../widget/keystore.dart';
// import 'home/empty.dart';
// import 'search_asset.dart';

class Wallet extends HookWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final assetList = useState<List<sdk.Asset>>([]);
    // final chains = useState<Map<String, String>>({});
    // final loading = useState(true);

    // Future<void> loadBalance() async {
    //   final keystore = await getKeyStore();
    //   if (keystore == null) {
    //     return;
    //   }

    //   final assets = await context.appServices.getAssetList(
    //     keystore: keystore,
    //   );
    //   final bot = context.appServices.getClientWithKeyStore(keystore);

    //   final chains0 = chains.value;
    //   for (final asset in assets) {
    //     if ((chains0[asset.chainId] ?? '').isEmpty) {
    //       final rsp = await bot.assetApi.getAssetById(asset.chainId);
    //       final chain = rsp.data;
    //       chains0[chain.assetId] = chain.iconUrl;
    //     }
    //   }

    //   assetList.value = assets;
    //   chains.value = chains0;
    //   loading.value = false;
    // }

    // useMemoizedFuture(loadBalance);

    // final checkedLogined = useState(false);

    final authChange = useValueListenable(isAuthChange);
    final loginFlag = useMemoized(() => isLogin, [authChange]);

    // useEffect(() {
    //   scheduleMicrotask(() async {
    //     final keystore = await getKeyStore();
    //     if (keystore == null || !isLogin) {
    //       await Navigator.of(context).push(
    //         MaterialPageRoute<void>(
    //           builder: (context) => const KeyStoreWidget(),
    //         ),
    //       );
    //     }

    //     checkedLogined.value = true;
    //     // if (isLogin) {
    //     //   context.vRouter.to('/mixin_wallet');
    //     // } else {
    //     //   context.vRouter.to('/');
    //     // }
    //   });
    //   // final timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
    //   //   try {
    //   //     await loadBalance();
    //   //   } catch (err) {
    //   //     e('$err');
    //   //   }
    //   // });
    //   // return timer.cancel;
    //   return () {};
    // }, []);

    if (loginFlag) {
      return const Home();
    } else {
      return const KeyStoreWidget();
    }

    // return Scaffold(
    //   backgroundColor: context.theme.background,
    //   appBar: const TopAppBar(),
    //   body: CustomScrollView(
    //     slivers: [
    //       if (loading.value)
    //         const SliverToBoxAdapter(
    //           child: Center(
    //             child: CircularProgressIndicator(),
    //           ),
    //         )
    //       else
    //         SliverToBoxAdapter(
    //           child: IconButton(
    //             icon: const Icon(
    //               Icons.add,
    //               color: Colors.red,
    //             ),
    //             onPressed: () async {
    //               await Navigator.of(context).push(
    //                 MaterialPageRoute<sdk.Asset?>(
    //                   builder: (context) => const SearchAsset(),
    //                 ),
    //               );
    //             },
    //           ),
    //         ),
    //       _AssetsSliverList(
    //         assetList: assetList.value,
    //         chains: chains.value,
    //       ),
    //     ],
    //   ),
    // );
  }
}

// class _AssetsSliverList extends StatelessWidget {
//   const _AssetsSliverList({
//     Key? key,
//     required this.assetList,
//     required this.chains,
//   }) : super(key: key);
//
//   final List<sdk.Asset> assetList;
//   final Map<String, String> chains;
//
//   @override
//   Widget build(BuildContext context) {
//     if (assetList.isEmpty) {
//       return SliverFillRemaining(
//         child: EmptyLayout(content: context.l10n.noAsset),
//       );
//     }
//     return SliverList(
//       delegate: SliverChildBuilderDelegate(
//         (BuildContext context, int index) {
//           final item = assetList[index];
//           return _AssetWidget(data: item, chainUrl: chains[item.chainId]);
//         },
//         childCount: assetList.length,
//       ),
//     );
//   }
// }
//
// class _AssetWidget extends StatelessWidget {
//   const _AssetWidget({
//     Key? key,
//     required this.data,
//     this.chainUrl,
//   }) : super(key: key);
//
//   final sdk.Asset data;
//   final String? chainUrl;
//
//   @override
//   Widget build(BuildContext context) {
//     Future<void> handlePay() async {
//       final dialog = DialogBuilder(
//         context,
//         autoHide: false,
//       );
//       if (mixinAuth == null) {
//         dialog
//           ..showError('Mixin钱包未绑定')
//           ..dispose();
//         return;
//       }
//       final keystore = await getKeyStore();
//       if (keystore == null) {
//         dialog
//           ..showError('KeyStore is not set')
//           ..dispose();
//         return;
//       }
//       final encryptedPin = sdk.encryptPin(
//         keystore.pin,
//         keystore.pinToken,
//         keystore.privateKey,
//         DateTime.now().microsecondsSinceEpoch * 1000,
//       );
//       final bot = context.appServices.getClientWithKeyStore(keystore);
//       final rsp = await dialog.process(
//         () => bot.transferApi.transfer(
//           sdk.TransferRequest(
//             assetId: data.assetId,
//             amount: data.balance,
//             opponentId: mixinAuth!.account.userId,
//             pin: encryptedPin,
//             memo: '提现到mixin钱包',
//           ),
//         ),
//       );
//
//       if (rsp == null) {
//         dialog.title.value = '提现失败';
//       } else {
//         dialog.title.value = '提现成功';
//       }
//       dialog.text.value = '';
//
//       await Future<void>.delayed(const Duration(seconds: 2));
//       dialog.dispose();
//     }
//
//     return Container(
//       height: 80,
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           SymbolIconWithBorder(
//             symbolUrl: data.iconUrl,
//             chainUrl: chainUrl,
//             size: 40,
//             chainSize: 14,
//             chainBorder: BorderSide(
//               color: context.colorScheme.background,
//               width: 1.5,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       ' ${data.symbol}'.overflow,
//                       style: TextStyle(
//                         color: context.colorScheme.primaryText,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   data.name,
//                   style: TextStyle(
//                     color: context.colorScheme.thirdText,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           _AssetPrice(data: data),
//           TextButton(
//             onPressed: handlePay,
//             child: const Text('提现'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _AssetPrice extends StatelessWidget {
//   const _AssetPrice({
//     Key? key,
//     required this.data,
//   }) : super(key: key);
//
//   final sdk.Asset data;
//
//   @override
//   Widget build(BuildContext context) => Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           Text(
//             data.balance,
//             textAlign: TextAlign.right,
//             style: TextStyle(
//               color: context.colorScheme.thirdText,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       );
// }
