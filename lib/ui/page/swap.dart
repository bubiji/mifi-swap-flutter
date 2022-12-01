import 'dart:async';

import 'package:compute/compute.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uniswap_sdk_dart/uniswap_sdk_dart.dart' as mifiswap;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:vrouter/vrouter.dart';

import '../../db/mixin_database.dart';
import '../../service/profile/keystore.dart';
import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/logger.dart';
import '../../util/r.dart';
import '../../util/swap_asset.dart';
import '../../util/swap_pair.dart';
// import '../router/mixin_routes.dart';
import '../widget/account.dart';
import '../widget/connect_wallet.dart';
import '../widget/dialog_builder.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/pre_order_meta.dart';
import '../widget/search_swap_asset_list.dart';
// import '../widget/swap_code.dart';
import '../widget/symbol.dart';

const kQueryParameterInput = 'input';
const kQueryParameterOutput = 'output';

const defaultAssetId = 'c94ac88f-4671-3976-b60a-09064f1811e8';
const btcAssetId = 'c6d0c728-2624-429b-8e0d-d9d19b6592fa';

const splitCount = 10;

PreOrderResult runGetPreOrder(List<dynamic> args) {
  final routes = args[0] as SwapPairRoutes;
  final params = args[1] as SwapParams;
  return routes.getPreOrder(params);
}

Uri genPayWithMixin({
  required String recipient,
  required String asset,
  required String amount,
}) =>
    Uri(
      scheme: 'mixin',
      host: 'pay',
      queryParameters: {
        'recipient': recipient,
        'asset': asset,
        'trace': const Uuid().v4(),
        'amount': amount,
        'memo': 'Pay for MifiSwap',
      },
    );

Future<void> tryLaunchUrl(Uri uri) async {
  try {
    await launchUrl(uri);
  } catch (err) {
    e('$err');
  }
}

class Swap extends HookWidget {
  const Swap({Key? key}) : super(key: key);

  void handleInputOutput(BuildContext context, String input, String output) {
    final params = Map<String, String>.from(context.queryParameters);
    params[kQueryParameterInput] = input;
    params[kQueryParameterOutput] = output;
    setDbInputAssetId(input);
    setDbOutputAssetId(output);
    context.replace(Uri(path: context.path).replace(queryParameters: params));
  }

  @override
  Widget build(BuildContext context) {
    useMemoizedFuture(() => context.appServices.updateSwapPairsAndSwapAssets());

    final inputParam =
        useQueryParameter(kQueryParameterInput, path: context.path);

    final outputParam =
        useQueryParameter(kQueryParameterOutput, path: context.path);

    final swapPairResults = useMemoizedStream(
      () => context.appServices.mixinDatabase.swapPairDao.getAll().watch(),
      initialData: <SwapPair>[],
    ).requireData;

    final routes = useMemoized(
        () => SwapPairRoutes()..makeRoutes(swapPairResults), [swapPairResults]);

    final swapAssetResults = useMemoizedStream(
      () => context.appServices.mixinDatabase.swapAssetDao.getAll().watch(),
      initialData: <SwapAsset>[],
    ).requireData;

    final swapAssetList = useMemoized(() {
      if (swapPairResults.isEmpty) {
        return <SwapAssetMeta>[];
      }
      return swapAssetResults
          // .where((swapAsset) => !(swapAsset.symbol ?? '').contains('-'))
          .map((swapAsset) =>
              getSwapAssetSwapPairsMeta(swapAsset, swapPairResults))
          .toList();
    }, [swapAssetResults, swapPairResults]);

    if (swapAssetList.isEmpty) {
      return Scaffold(
          backgroundColor: context.theme.background,
          appBar: const TopAppBar(),
          body: Center(child: Text(context.l10n.loadding)));
    }

    final inputAssetId = useMemoized(() {
      if (inputParam.isNotEmpty) {
        return inputParam;
      }
      return dbInputAssetId ?? defaultAssetId;
    }, [inputParam, swapPairResults]);

    final outputAssetId = useMemoized(() {
      if (outputParam.isNotEmpty) {
        return outputParam;
      }
      return dbOutputAssetId ?? btcAssetId;
    }, [outputParam, swapPairResults]);

    SwapAssetMeta? getSwapAssetById(String id) {
      final idx =
          swapAssetList.indexWhere((swapAsset) => swapAsset.swapAsset.id == id);
      if (idx > -1) {
        return swapAssetList[idx];
      }
      return null;
    }

    final inputSwapAsset = useMemoized(
        () => getSwapAssetById(inputAssetId) ?? swapAssetList[0],
        [inputAssetId]);

    final outputSwapAsset = useMemoized(
        () => getSwapAssetById(outputAssetId) ?? swapAssetList[1],
        [outputAssetId]);

    final outputSwapAssetList = useMemoized(() {
      final assetIds = routes.getAssetIds(inputAssetId);
      return swapAssetList
          .where((swapAsset) => assetIds.contains(swapAsset.swapAsset.id))
          .toList();
    }, [inputAssetId, routes]);

    final inputNotifier = useState(inputAssetId);
    final outputNotifier = useState(outputAssetId);

    useMemoized(() {
      if (inputNotifier.value != inputAssetId ||
          outputNotifier.value != outputAssetId) {
        handleInputOutput(context, inputNotifier.value, outputNotifier.value);
      }
    }, [inputNotifier.value, outputNotifier.value]);

    final inputController = useTextEditingController();
    final outputController = useTextEditingController();

    final size = MediaQuery.of(context).size;
    final width = size.width;

    final preOrderMeta = useState<PreOrderMeta?>(null);
    final preOrderMeta10 = useState<PreOrderMeta?>(null);
    final isCalcPreOrder = useState(true);

    Future<PreOrderMeta?> calcPreOrder({
      String? input,
      String? output,
      String scale = '1',
    }) async {
      i('input: ${inputSwapAsset.swapAsset.id}:$input, output: ${outputSwapAsset.swapAsset.id}:$output');
      final params = SwapParams(
        inputSwapAsset: inputSwapAsset.swapAsset.id,
        outputSwapAsset: outputSwapAsset.swapAsset.id,
        inputAmount: input ?? output ?? '',
        inputScale: scale,
      );
      if (params.inputAmount.isEmpty) {
        return null;
      }

      final result = await compute(runGetPreOrder, [routes, params]);
      final err = result.error;
      final preOrder = result.preOrder;
      if (err != null) {
        i(err);
        return null;
      }
      if (preOrder == null) {
        return null;
      }
      final amount = preOrder.amount;
      final funds = preOrder.funds;
      if (input == null) {
        return PreOrderMeta(
          inputSwapAsset: inputSwapAsset.swapAsset,
          outputSwapAsset: outputSwapAsset.swapAsset,
          swapPairs: swapPairResults,
          swapAssets: swapAssetResults,
          amount: funds.asDecimal,
          funds: amount.asDecimal,
          order: preOrder,
        );
      } else {
        return PreOrderMeta(
          inputSwapAsset: inputSwapAsset.swapAsset,
          outputSwapAsset: outputSwapAsset.swapAsset,
          swapPairs: swapPairResults,
          swapAssets: swapAssetResults,
          amount: amount.asDecimal,
          funds: funds.asDecimal,
          order: preOrder,
        );
      }
    }

    final timer = useRef<Timer?>(null);
    final currentRequest = useRef<DateTime?>(null);

    // mixinpay
    void handleGetPreOrder(String? input, String? output) {
      isCalcPreOrder.value = true;
      final id = DateTime.now();
      currentRequest.value = id;
      timer.value?.cancel();
      timer.value = Timer(const Duration(milliseconds: 150), () async {
        final orderMeta10 = await calcPreOrder(
          input: input,
          output: output,
          scale: '$splitCount',
        );

        if (currentRequest.value != id) {
          return;
        }

        final orderMeta = await calcPreOrder(input: input, output: output);

        if (currentRequest.value != id) {
          return;
        }

        if (input == null) {
          inputController.text = orderMeta10?.funds.toStringAsFixed(8) ?? '';
        } else {
          outputController.text = orderMeta10?.amount.toStringAsFixed(8) ?? '';
        }

        preOrderMeta10.value = orderMeta10;
        preOrderMeta.value = orderMeta;
        isCalcPreOrder.value = false;
      });
    }

    useMemoized(() {
      handleGetPreOrder(inputController.text, null);
    }, [inputSwapAsset.swapAsset.id, outputSwapAsset.swapAsset.id]);

    final assetResults = useMemoizedStream(
      () => context.mixinDatabase.assetDao.getAll().watch(),
      initialData: <Asset>[],
    ).requireData;

    final balance = useMemoized(() {
      final balance = <String, String>{};
      assetResults.forEach((v) {
        balance[v.assetId] = v.balance;
      });
      return balance;
    }, [assetResults]);

    // final balance = useState(<String, String>{});
    final authChange = useValueListenable(isAuthChange);
    final loginFlag = useMemoized(() => isLogin, [authChange]);
    // Future<void> loadBalance() async {
    //   if (isLogin) {
    //     balance.value = await context.appServices.getBalance();
    //   } else {
    //     balance.value = {};
    //   }
    // }

    // useMemoizedFuture(loadBalance);

    // useEffect(() {
    //   final timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
    //     try {
    //       await loadBalance();
    //     } catch (err) {
    //       e('$err');
    //     }
    //   });
    //   return timer.cancel;
    // }, []);

    Future<KeyStore?> getOrCreateKeyStore(DialogBuilder dialog) async {
      final keystore = await getKeyStore();
      if (keystore != null) {
        return keystore;
      }
      dialog.text.value = 'Generate Local Account......';
      const name = 'MifiSwap Local Account';
      return dialog.process<KeyStore>(
        () => context.appServices.createKeyStore(name),
      );
    }

    Future<Decimal> checkBalance(
      DialogBuilder dialog,
      String totalAmount,
    ) async {
      // await dialog.process(
      //   () => context.appServices.updateAsset(inputAssetId)
      // );
      final asset =
          await context.appServices.assetResult(inputAssetId).getSingleOrNull();
      final v = asset?.balance ?? '0';
      final symbol = asset?.symbol ?? '';
      dialog.text.value =
          '${context.l10n.balance} $v $symbol ${context.l10n.need} $totalAmount $symbol';
      return totalAmount.asDecimal - v.asDecimal;
    }

    Future<void> handleSwapWithKeyStore(
      PreOrderMeta orderMeta, {
      int splitCount = 1,
    }) async {
      Navigator.of(context).pop(false);

      final dialog = DialogBuilder(context, autoHide: false);

      final keystore = await getOrCreateKeyStore(dialog);
      if (keystore == null) {
        dialog
          ..showError('KeyStore is not set')
          ..dispose();
        return;
      }

      dialog.showLoadingIndicator();

      final totalAmount = inputController.text;
      dialog.title.value = context.l10n.checkbalance;
      var requiredAmount = await checkBalance(dialog, totalAmount);

      if (requiredAmount > Decimal.zero && mixinAuth != null) {
        final uri = genPayWithMixin(
          recipient: keystore.clientId,
          asset: inputAssetId,
          amount: requiredAmount.toStringAsFixed(8),
        );

        var canceled = false;

        dialog.children.value = getPayDialog(
          payUrl: uri.toString(),
          onOpenMixin: () => tryLaunchUrl(uri),
          onCancel: () {
            canceled = true;
            dialog.dispose();
          },
        );

        for (var i = 0; i < 120; i++) {
          dialog.title.value = '${context.l10n.waitforthedeposit} $i s......';
          await Future<void>.delayed(const Duration(seconds: 1));
          requiredAmount = await checkBalance(dialog, totalAmount);
          if (requiredAmount <= Decimal.zero) {
            break;
          }

          if (canceled) {
            return;
          }
        }
        dialog.children.value = [];
      }

      if (requiredAmount > Decimal.zero) {
        await Future<void>.delayed(const Duration(seconds: 1));
        dialog.title.value = context.l10n.insufficientbalancePleasedeposit;
        dialog.text.value = context.l10n.jumpingAdress;
        await Future<void>.delayed(const Duration(seconds: 2));
        context.vRouter.to('/tokens/$inputAssetId/deposit');
        return;
      }

      final scale = (1 / splitCount).asDecimal;
      final amount = inputController.text.asDecimal * scale;
      final minReceived = orderMeta.minReceived * scale;
      final routes = orderMeta.order.routes;

      final receiverId = (mixinAuth ?? auth)!.account.userId;

      var failed = false;

      for (var i = 0; i < splitCount; i++) {
        final header = '${context.l10n.trading} (${i + 1}/$splitCount) ';
        dialog.title.value = '$header ......';
        dialog.text.value = context.l10n.createtradingOrder;
        final followId = const Uuid().v4();

        final action = await dialog.process<mifiswap.Action>(
          () => context.appServices.createSwapAction(
            receiverId: receiverId,
            inputAssetId: inputAssetId,
            outputAssetId: outputAssetId,
            followId: followId,
            amount: amount.toString(),
            routes: routes,
            minReceived: minReceived.toString(),
          ),
        );
        if (action == null) {
          dialog
            ..showError('Create swap action filed')
            ..dispose();
          return;
        }
        for (var tryCount = 0; tryCount < 10; tryCount++) {
          dialog.text.value =
              '${context.l10n.trytopayforthextime}${tryCount + 1}${context.l10n.times}';
          await Future<void>.delayed(Duration(
            seconds: 1,
            milliseconds: tryCount * 250,
          ));

          final r = await dialog.process<bool>(
            () async {
              await context.appServices.payWithKeyStore(
                keystore: keystore,
                assetId: inputAssetId,
                memo: action.action,
                traceId: followId,
                amount: amount.toString(),
              );
              return true;
            },
            hideError: true,
          );
          if (r ?? false) {
            break;
          } else {
            if (tryCount >= 9) {
              failed = true;
            }
          }
        }
        if (failed) {
          break;
        }
      }

      if (failed) {
        dialog.title.value = context.l10n.swapfailed;
        dialog.text.value = '';
      } else {
        dialog.title.value = context.l10n.success;
        dialog.text.value = context.l10n.swapSuccessfully;
      }
      await Future<void>.delayed(const Duration(seconds: 2));
      dialog.dispose();
      inputController.text = '';
      outputController.text = '';
      preOrderMeta.value = null;
      preOrderMeta10.value = null;
    }

    // pop dialog
    void showDialogFunction() {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            context.l10n.confirmation,
            textAlign: TextAlign.center,
          ),
          titlePadding: const EdgeInsets.all(20),
          titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 16),
          content: Stack(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SymbolIconWithBorder(
                            symbolUrl: inputSwapAsset.swapAsset.logo,
                            chainUrl: inputSwapAsset.swapAsset.chainLogo,
                            size: 24,
                            chainSize: 8,
                            chainBorder: BorderSide(
                              color: context.colorScheme.background,
                              width: 1.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            ' ${inputSwapAsset.swapAsset.symbol}'.overflow,
                            style: TextStyle(
                              color: context.colorScheme.primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      //pay value
                      Text((inputController.text == '')
                          ? '- 0.00'
                          : '-${inputController.text}')
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SymbolIconWithBorder(
                            symbolUrl: outputSwapAsset.swapAsset.logo,
                            chainUrl: outputSwapAsset.swapAsset.chainLogo,
                            size: 24,
                            chainSize: 8,
                            chainBorder: BorderSide(
                              color: context.colorScheme.background,
                              width: 1.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            ' ${outputSwapAsset.swapAsset.symbol}'.overflow,
                            style: TextStyle(
                              color: context.colorScheme.primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Text('+${preOrderMeta10.value!.amount.toStringAsFixed(8)}'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // const Text('拆$splitCount单'),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // split outcome
                      Text(
                        '${context.l10n.spiltoutcome} : ${(preOrderMeta10.value!.amount - preOrderMeta.value!.amount).toStringAsFixed(8)}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20.0),
          contentTextStyle: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => handleSwapWithKeyStore(
                preOrderMeta10.value!,
                splitCount: splitCount,
              ),
              child: Text(context.l10n.continueText), //$splitCount
            ),
            // TextButton(
            //   onPressed: handleSwap,
            //   child: Text(context.l10n.continueText),
            // ),
            TextButton(
              child: Text(context.l10n.cancel),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: context.theme.background,
        appBar: const TopAppBar(),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsetsDirectional.all(10),
                child: Text(context.l10n.mifiswap),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                margin: const EdgeInsetsDirectional.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFcccccc),
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
                child: Stack(
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: InkResponse(
                                    radius: 24,
                                    onTap: () => showMixinBottomSheet<void>(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (BuildContext context) =>
                                          SearchSwapAssetList(
                                        swapAssetList: swapAssetList,
                                        notifier: inputNotifier,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        SymbolIconWithBorder(
                                          symbolUrl:
                                              inputSwapAsset.swapAsset.logo,
                                          chainUrl: inputSwapAsset
                                              .swapAsset.chainLogo,
                                          size: 24,
                                          chainSize: 8,
                                          chainBorder: BorderSide(
                                            color:
                                                context.colorScheme.background,
                                            width: 1.5,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          ' ${inputSwapAsset.swapAsset.symbol}'
                                              .overflow,
                                          style: TextStyle(
                                            color:
                                                context.colorScheme.primaryText,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        SvgPicture.asset(
                                          R.resourcesDownSvg,
                                          height: 18,
                                          width: 18,
                                          color:
                                              context.colorScheme.primaryText,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    obscureText: false,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                    textAlign: TextAlign.right,
                                    controller: inputController,
                                    textInputAction: TextInputAction.done,
                                    onChanged: (value) =>
                                        handleGetPreOrder(value, null),
                                    decoration: InputDecoration(
                                      hintText: context.l10n.from,
                                      contentPadding: EdgeInsets.zero,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: BorderSide.none),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin:
                                  const EdgeInsetsDirectional.only(bottom: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (loginFlag) ...[
                                    InkResponse(
                                      radius: 24,
                                      onTap: () {
                                        inputController.text = balance[
                                                inputSwapAsset.swapAsset.id] ??
                                            '0';
                                        handleGetPreOrder(
                                            balance[inputSwapAsset
                                                    .swapAsset.id] ??
                                                '0',
                                            null);
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(balance[inputSwapAsset
                                                  .swapAsset.id] ??
                                              '0'),
                                          const SizedBox(width: 6),
                                          SvgPicture.asset(
                                            R.resourcesUprightSvg,
                                            height: 10,
                                            width: 10,
                                            color:
                                                context.colorScheme.primaryText,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else ...[
                                    InkResponse(
                                      radius: 24,
                                      onTap: () => showMixinBottomSheet<void>(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (BuildContext context) =>
                                            const ConnectWallet(),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            context.l10n.createAccount,
                                            style: TextStyle(
                                              color: context
                                                  .colorScheme.primaryText,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          SvgPicture.asset(
                                            R.resourcesConcatSvg,
                                            height: 10,
                                            width: 10,
                                            color:
                                                context.colorScheme.primaryText,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  Text((inputController.text == '')
                                      ? r'$ 0.00'
                                      : r'$' +
                                          (inputController.text.asDecimal *
                                                  inputSwapAsset.swapAsset.price
                                                      .asDecimal)
                                              .toStringAsFixed(2))
                                ],
                              ),
                            )
                          ],
                        ),
                        Container(
                          height: 1,
                          color: const Color(0xFFbbbbbb),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: InkResponse(
                                    radius: 24,
                                    onTap: () => showMixinBottomSheet<void>(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (BuildContext context) =>
                                          SearchSwapAssetList(
                                              swapAssetList:
                                                  outputSwapAssetList,
                                              notifier: outputNotifier),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        SymbolIconWithBorder(
                                          symbolUrl:
                                              outputSwapAsset.swapAsset.logo,
                                          chainUrl: outputSwapAsset
                                              .swapAsset.chainLogo,
                                          size: 24,
                                          chainSize: 8,
                                          chainBorder: BorderSide(
                                            color:
                                                context.colorScheme.background,
                                            width: 1.5,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          ' ${outputSwapAsset.swapAsset.symbol}'
                                              .overflow,
                                          style: TextStyle(
                                            color:
                                                context.colorScheme.primaryText,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        SvgPicture.asset(
                                          R.resourcesDownSvg,
                                          height: 18,
                                          width: 18,
                                          color:
                                              context.colorScheme.primaryText,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    obscureText: false,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                    textAlign: TextAlign.right,
                                    controller: outputController,
                                    textInputAction: TextInputAction.done,
                                    onChanged: (value) =>
                                        handleGetPreOrder(null, value),
                                    decoration: InputDecoration(
                                      hintText: context.l10n.to,
                                      contentPadding: EdgeInsets.zero,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: BorderSide.none),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            //section 1
                            Container(
                              margin:
                                  const EdgeInsetsDirectional.only(bottom: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (loginFlag) ...[
                                    InkResponse(
                                      radius: 24,
                                      onTap: () {
                                        outputController.text = balance[
                                                outputSwapAsset.swapAsset.id] ??
                                            '0';
                                        handleGetPreOrder(
                                            null,
                                            balance[outputSwapAsset
                                                    .swapAsset.id] ??
                                                '0');
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(balance[outputSwapAsset
                                                  .swapAsset.id] ??
                                              '0'),
                                          const SizedBox(width: 6),
                                          SvgPicture.asset(
                                            R.resourcesUprightSvg,
                                            height: 10,
                                            width: 10,
                                            color:
                                                context.colorScheme.primaryText,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else ...[
                                    InkResponse(
                                        radius: 24,
                                        onTap: () => showMixinBottomSheet<void>(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (BuildContext context) =>
                                                const ConnectWallet()),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                context.l10n.createAccount,
                                                style: TextStyle(
                                                  color: context
                                                      .colorScheme.primaryText,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              SvgPicture.asset(
                                                R.resourcesConcatSvg,
                                                height: 10,
                                                width: 10,
                                                color: context
                                                    .colorScheme.primaryText,
                                              ),
                                            ])),
                                  ],
                                  Text((outputController.text == '')
                                      ? r'$ 0.00'
                                      : r'$' +
                                          (outputController.text.asDecimal *
                                                  outputSwapAsset.swapAsset
                                                      .price.asDecimal)
                                              .toStringAsFixed(2))
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Positioned(
                      top: 64,
                      right: width / 2 - 44,
                      child: InkResponse(
                        radius: 24,
                        child: SvgPicture.asset(
                          R.resourcesSwapSvg,
                          height: 24,
                          width: 24,
                          color: context.colorScheme.primaryText,
                        ),
                        onTap: () {
                          handleInputOutput(
                              context, outputAssetId, inputAssetId);
                          final temp = inputController.text;
                          inputController.text = outputController.text;
                          outputController.text = temp;
                          handleGetPreOrder(
                              inputController.text, outputController.text);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (preOrderMeta.value != null && preOrderMeta10.value != null) ...[
              PreOrderMetaWidget(
                  preOrderMeta: preOrderMeta.value!,
                  preOrderMeta10: preOrderMeta10.value!,
                  inputSymbol: inputSwapAsset.swapAsset.symbol ?? '',
                  outputSymbol: outputSwapAsset.swapAsset.symbol ?? '',
                  splitCount: splitCount),
            ],
            SliverToBoxAdapter(
              child: Container(
                height: 20,
              ),
            ),
            if (loginFlag) ...[
              SliverToBoxAdapter(
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 40,
                    child: ElevatedButton(
                      onPressed:
                          isCalcPreOrder.value || preOrderMeta10.value == null
                              ? null
                              : showDialogFunction,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: Color(0xFFcccccc),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 24),
                          Expanded(
                            child: Center(
                              child: Text(context.l10n.splitswap),
                            ),
                          ),
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: isCalcPreOrder.value
                                ? const CircularProgressIndicator(
                                    strokeWidth: 3)
                                : const SizedBox(),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              SliverToBoxAdapter(
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => showMixinBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) =>
                              const ConnectWallet()),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: Color(0xFFcccccc),
                          ),
                        ),
                      ),
                      child: Text(context.l10n.createAccount),
                    ),
                  ),
                ),
              ),
            ],
            if (preOrderMeta.value != null && preOrderMeta10.value != null) ...[
              MorePreOrderMetaWidget(
                  preOrderMeta: preOrderMeta.value!,
                  preOrderMeta10: preOrderMeta10.value!,
                  inputSymbol: inputSwapAsset.swapAsset.symbol ?? '',
                  outputSymbol: outputSwapAsset.swapAsset.symbol ?? '',
                  splitCount: splitCount),
            ],
          ],
        ),
      ),
    );
  }
}

//more ref info
class MorePreOrderMetaWidget extends HookWidget {
  const MorePreOrderMetaWidget({
    required this.preOrderMeta,
    required this.preOrderMeta10,
    required this.inputSymbol,
    required this.outputSymbol,
    required this.splitCount,
    Key? key,
  }) : super(key: key);
  final PreOrderMeta preOrderMeta;
  final PreOrderMeta preOrderMeta10;
  final String inputSymbol;
  final String outputSymbol;
  final int splitCount;
  // final double size = 18;

  @override
  Widget build(BuildContext context) {
    const textStyleblack12 = TextStyle(
      color: Colors.black38,
      fontSize: 15,
    );
    // const textStyleblack = TextStyle(
    //   color: Colors.black,
    //   fontSize: 20,
    // );
    // final showReverse = useState<bool>(false);
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsetsDirectional.all(10),
        child: Column(
          children: [
            Container(
              height: 30,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.minRecevied,
                  style: textStyleblack12,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                        '${preOrderMeta.minReceivedText} $outputSymbol'
                            .overflow,
                        style: textStyleblack12),
                    Container(width: 10),
                    InkResponse(
                      radius: 14,
                      child: SvgPicture.asset(
                        R.resourcesProblemSvg,
                        height: 14,
                        width: 14,
                        color: context.colorScheme.thirdText,
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
            //section 4
            Container(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.fee,
                  style: textStyleblack12,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      '${preOrderMeta.feeText} $inputSymbol'.overflow,
                      style: textStyleblack12,
                    ),
                    Container(width: 10),
                    InkResponse(
                      radius: 14,
                      child: SvgPicture.asset(
                        R.resourcesProblemSvg,
                        height: 14,
                        width: 14,
                        color: context.colorScheme.thirdText,
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height: 10,
            ),
            // Row(
            //   mainAxisSize: MainAxisSize.max,
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       context.l10n.spiltfeeoutcome,
            //       style: _textStyleblack12,
            //     ),
            //     Text(
            //       context.l10n.local == 'en'
            //           ? '${preOrderMeta.fee - preOrderMeta10.fee} $inputSymbol'
            //               .overflow
            //           : '${preOrderMeta10.fee - preOrderMeta.fee} $inputSymbol'
            //               .overflow,
            //       style: _textStyleblack12,
            //     ),
            //   ],
            // ),
            // Container(
            //   height: 10,
            // ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.priceImpact,
                  style: textStyleblack12,
                ),
                Text(
                  preOrderMeta.order.ctx.priceImpact.toPercentage,
                  style: textStyleblack12,
                ),
              ],
            ),
            Container(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.route,
                  style: textStyleblack12,
                ),
                Text(
                  preOrderMeta.routes,
                  style: textStyleblack12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
