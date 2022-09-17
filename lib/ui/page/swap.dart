import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:uniswap_sdk_dart/uniswap_sdk_dart.dart' as forswap;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../db/mixin_database.dart';
import '../../service/profile/profile_manager.dart';
import '../../util/asset.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/logger.dart';
import '../../util/pair.dart';
import '../../util/r.dart';
// import '../router/mixin_routes.dart';
import '../widget/account.dart';
import '../widget/auth.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/search_asset_list.dart';
import '../widget/swap_code.dart';
import '../widget/symbol.dart';

const kQueryParameterInput = 'input';
const kQueryParameterOutput = 'output';

const defaultAssetId = 'c94ac88f-4671-3976-b60a-09064f1811e8';
const btcAssetId = 'c6d0c728-2624-429b-8e0d-d9d19b6592fa';

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
    useMemoizedFuture(() => context.appServices.updatePairs());

    final inputParam =
        useQueryParameter(kQueryParameterInput, path: context.path);

    final outputParam =
        useQueryParameter(kQueryParameterOutput, path: context.path);

    final pairResults = useMemoizedStream(
      () => context.appServices.mixinDatabase.pairDao.getAll().watch(),
      initialData: <Pair>[],
    ).requireData;

    final routes =
        useMemoized(() => PairRoutes()..makeRoutes(pairResults), [pairResults]);

    final assetResults = useMemoizedStream(
      () => context.appServices.mixinDatabase.assetDao.getAll().watch(),
      initialData: <Asset>[],
    ).requireData;

    final assetList = useMemoized(() {
      if (pairResults.isEmpty) {
        return <AssetMeta>[];
      }
      return assetResults
          // .where((asset) => !(asset.symbol ?? '').contains('-'))
          .map((asset) => getAssetMeta(asset, pairResults))
          .toList();
    }, [assetResults, pairResults]);

    if (assetList.isEmpty) {
      return Scaffold(
          backgroundColor: context.theme.background,
          appBar: const TopAppBar(),
          body: const Center(child: Text('Loadding...')));
    }

    final inputAssetId = useMemoized(() {
      if (inputParam.isNotEmpty) {
        return inputParam;
      }
      return dbInputAssetId ?? defaultAssetId;
    }, [inputParam, pairResults]);

    final outputAssetId = useMemoized(() {
      if (outputParam.isNotEmpty) {
        return outputParam;
      }
      return dbOutputAssetId ?? btcAssetId;
    }, [outputParam, pairResults]);

    AssetMeta? getAssetById(String id) {
      final idx = assetList.indexWhere((asset) => asset.asset.id == id);
      if (idx > -1) {
        return assetList[idx];
      }
      return null;
    }

    final inputAsset = useMemoized(
        () => getAssetById(inputAssetId) ?? assetList[0], [inputAssetId]);

    final outputAsset = useMemoized(
        () => getAssetById(outputAssetId) ?? assetList[1], [outputAssetId]);

    final outputAssetList = useMemoized(() {
      final assetIds = routes.getAssetIds(inputAssetId);
      return assetList
          .where((asset) => assetIds.contains(asset.asset.id))
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

    void handleGetPreOrder(String? input, String? output) {
      i('input: ${inputAsset.asset.id}:$input, output: ${outputAsset.asset.id}:$output');
      var params = SwapParams(
        inputAsset: inputAsset.asset.id,
        outputAsset: outputAsset.asset.id,
        inputAmount: input,
      );

      if (input == null) {
        params = SwapParams(
          inputAsset: outputAsset.asset.id,
          outputAsset: inputAsset.asset.id,
          inputAmount: output,
        );
      }
      scheduleMicrotask(() {
        try {
          routes.getPreOrder(params, (err, preOrder) {
            if (err != null) {
              i(err);
              return;
            }
            if (preOrder == null) {
              return;
            }
            // print(preOrder?.ctx.routeIds);
            // print(preOrder?.ctx.routeAssets);
            // print(preOrder?.funds);
            // print(preOrder?.amount);
            final amount = preOrder.amount;
            final funds = preOrder.funds;
            if (input == null) {
              inputController.text = amount;
              preOrderMeta.value = PreOrderMeta(
                inputAsset: inputAsset.asset,
                outputAsset: outputAsset.asset,
                pairs: pairResults,
                assets: assetResults,
                amount: funds.asDecimal,
                funds: amount.asDecimal,
                order: preOrder,
              );
            } else {
              outputController.text = amount;
              preOrderMeta.value = PreOrderMeta(
                inputAsset: inputAsset.asset,
                outputAsset: outputAsset.asset,
                pairs: pairResults,
                assets: assetResults,
                amount: amount.asDecimal,
                funds: funds.asDecimal,
                order: preOrder,
              );
            }

            print(preOrderMeta.value);
            // handleInputOutput(
            //     context, inputNotifier.value, outputNotifier.value);
          });
        } catch (e, stack) {
          i(e.toString());
          i(stack.toString());
        }
      });
    }

    useMemoized(() {
      handleGetPreOrder(inputController.text, null);
    }, [inputAsset.asset.id, outputAsset.asset.id]);

    final authChange = useValueListenable(isAuthChange);

    final myAssets = useMemoizedFuture(() async {
      if (isLogin) {
        final rsp = await context.appServices.bot.assetApi.getAssets();
        return rsp.data
            .where((asset) => asset.balance.asDecimal > Decimal.zero)
            .toList();
      }
      return [];
    }, initialData: <sdk.Asset>[], keys: [authChange]).requireData;

    final balance = useMemoized(() {
      final balance = <String, String>{};
      myAssets.forEach((v) {
        final asset = v as sdk.Asset;
        balance[asset.assetId] = asset.balance;
      });
      return balance;
    }, [myAssets]);

    // void onTap(String id) {
    //   context.push(assetDetailPath.toUri({'id': id}));
    // }

    Future<void> handleSwap() async {
      const uuid = Uuid();
      final id = auth!.account.userId;
      assert(preOrderMeta.value != null, 'PreOrderMeta should not be null');
      final orderMeta = preOrderMeta.value!;
      final followId = uuid.v4();
      final action = forswap.ActionProtoSwapCrypto(
        receiverId: id,
        followId: followId,
        fillAssetId: outputAsset.asset.id,
        routes: orderMeta.order.routes,
        minimum: orderMeta.minReceivedText,
      );
      print(action);
      final rsp = await context.appServices.fswap.createAction(
          action.toString(), inputController.text, inputAsset.asset.id);
      print(rsp);
      print('swap');
      final codeUrl = rsp.data?.codeUrl ?? '';

      if (codeUrl.isNotEmpty) {
        await launchUrl(Uri.parse(codeUrl));
      }

      await showMixinBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) => SwapCode(
              codeUrl: codeUrl,
              inputString:
                  inputController.text + ' ${inputAsset.asset.symbol}'.overflow,
              followId: followId,
              logo: inputAsset.asset.logo,
              chainLogo: inputAsset.asset.chainLogo));
    }

    final showReverse = useState<bool>(false);

    void showDialogFunction() {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            '确认',
            textAlign: TextAlign.center,
          ),
          titlePadding: const EdgeInsets.all(20),
          titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 16),
          content: Stack(children: <Widget>[
            Column(mainAxisSize: MainAxisSize.min, children: [
              Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(mainAxisSize: MainAxisSize.max, children: [
                      SymbolIconWithBorder(
                        symbolUrl: inputAsset.asset.logo,
                        chainUrl: inputAsset.asset.chainLogo,
                        size: 24,
                        chainSize: 8,
                        chainBorder: BorderSide(
                          color: context.colorScheme.background,
                          width: 1.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ' ${inputAsset.asset.symbol}'.overflow,
                        style: TextStyle(
                          color: context.colorScheme.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ]),
                    Text((inputController.text == '')
                        ? '- 0.00'
                        : '-${inputController.text}')
                  ]),
              const SizedBox(height: 6),
              Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(mainAxisSize: MainAxisSize.max, children: [
                      SymbolIconWithBorder(
                        symbolUrl: outputAsset.asset.logo,
                        chainUrl: outputAsset.asset.chainLogo,
                        size: 24,
                        chainSize: 8,
                        chainBorder: BorderSide(
                          color: context.colorScheme.background,
                          width: 1.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ' ${outputAsset.asset.symbol}'.overflow,
                        style: TextStyle(
                          color: context.colorScheme.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ]),
                    Text((outputController.text == '')
                        ? '+ 0.00'
                        : '+ ${outputController.text}')
                  ]),
            ])
          ]),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20.0),
          contentTextStyle:
              const TextStyle(color: Colors.black54, fontSize: 14),
          actions: <Widget>[
            TextButton(
              child: const Text('确认'),
              onPressed: () => {Navigator.of(context).pop(false), handleSwap()},
            ),
            TextButton(
              child: const Text('撤销'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      );
    }

    void showError(String err) {
      showDialog<void>(
        context: context,
        builder: (context) {
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            title: const Text(
              'error',
              textAlign: TextAlign.center,
            ),
            titlePadding: const EdgeInsets.all(20),
            titleTextStyle:
                const TextStyle(color: Colors.black87, fontSize: 16),
            content: Text(err),
            contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20.0),
            contentTextStyle:
                const TextStyle(color: Colors.black54, fontSize: 14),
          );
        },
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
              child: const Text('Swap'),
            )),
            SliverToBoxAdapter(
                child: Container(
                    padding: const EdgeInsets.all(20.0),
                    margin: const EdgeInsetsDirectional.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFcccccc),
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                    child: Stack(children: <Widget>[
                      Column(mainAxisSize: MainAxisSize.max, children: [
                        Column(mainAxisSize: MainAxisSize.max, children: [
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
                                              SearchAssetList(
                                                  assetList: assetList,
                                                  notifier: inputNotifier)),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            SymbolIconWithBorder(
                                              symbolUrl: inputAsset.asset.logo,
                                              chainUrl:
                                                  inputAsset.asset.chainLogo,
                                              size: 24,
                                              chainSize: 8,
                                              chainBorder: BorderSide(
                                                color: context
                                                    .colorScheme.background,
                                                width: 1.5,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              ' ${inputAsset.asset.symbol}'
                                                  .overflow,
                                              style: TextStyle(
                                                color: context
                                                    .colorScheme.primaryText,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SvgPicture.asset(
                                              R.resourcesDownSvg,
                                              height: 18,
                                              width: 18,
                                              color: context
                                                  .colorScheme.primaryText,
                                            ),
                                          ])),
                                ),
                                Expanded(
                                    child: TextField(
                                        obscureText: false,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                        textAlign: TextAlign.right,
                                        controller: inputController,
                                        textInputAction: TextInputAction.done,
                                        onChanged: (value) =>
                                            handleGetPreOrder(value, null),
                                        decoration: InputDecoration(
                                          hintText: 'From',
                                          contentPadding: EdgeInsets.zero,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              borderSide: BorderSide.none),
                                        )))
                              ]),
                          Container(
                              margin:
                                  const EdgeInsetsDirectional.only(bottom: 10),
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (isLogin) ...[
                                      Text(balance[inputAsset.asset.id] ?? '0'),
                                    ] else ...[
                                      InkResponse(
                                          radius: 24,
                                          onTap: () =>
                                              showMixinBottomSheet<void>(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder:
                                                      (BuildContext context) =>
                                                          const Auth()),
                                          child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Text(
                                                  'Connect Wallet',
                                                  style: TextStyle(
                                                    color: context.colorScheme
                                                        .primaryText,
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
                                    Text((inputController.text == '')
                                        ? r'$ 0.00'
                                        : r'$' +
                                            (inputController.text.asDecimal *
                                                    inputAsset
                                                        .asset.price.asDecimal)
                                                .toStringAsFixed(2))
                                  ]))
                        ]),
                        Container(
                          height: 1,
                          color: const Color(0xFFbbbbbb),
                        ),
                        Column(mainAxisSize: MainAxisSize.max, children: [
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
                                              SearchAssetList(
                                                  assetList: outputAssetList,
                                                  notifier: outputNotifier)),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            SymbolIconWithBorder(
                                              symbolUrl: outputAsset.asset.logo,
                                              chainUrl:
                                                  outputAsset.asset.chainLogo,
                                              size: 24,
                                              chainSize: 8,
                                              chainBorder: BorderSide(
                                                color: context
                                                    .colorScheme.background,
                                                width: 1.5,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              ' ${outputAsset.asset.symbol}'
                                                  .overflow,
                                              style: TextStyle(
                                                color: context
                                                    .colorScheme.primaryText,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SvgPicture.asset(
                                              R.resourcesDownSvg,
                                              height: 18,
                                              width: 18,
                                              color: context
                                                  .colorScheme.primaryText,
                                            ),
                                          ])),
                                ),
                                Expanded(
                                    child: TextField(
                                        obscureText: false,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                        textAlign: TextAlign.right,
                                        controller: outputController,
                                        textInputAction: TextInputAction.done,
                                        onChanged: (value) =>
                                            handleGetPreOrder(null, value),
                                        decoration: InputDecoration(
                                          hintText: 'To',
                                          contentPadding: EdgeInsets.zero,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              borderSide: BorderSide.none),
                                        )))
                              ]),
                          Container(
                              margin:
                                  const EdgeInsetsDirectional.only(bottom: 10),
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (isLogin) ...[
                                      Text(
                                          balance[outputAsset.asset.id] ?? '0'),
                                    ] else ...[
                                      InkResponse(
                                          radius: 24,
                                          onTap: () =>
                                              showMixinBottomSheet<void>(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder:
                                                      (BuildContext context) =>
                                                          const Auth()),
                                          child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Text(
                                                  'Connect Wallet',
                                                  style: TextStyle(
                                                    color: context.colorScheme
                                                        .primaryText,
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
                                                    outputAsset
                                                        .asset.price.asDecimal)
                                                .toStringAsFixed(2))
                                  ]))
                        ])
                      ]),
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
                            }),
                      ),
                    ]))),
            if (preOrderMeta.value != null) ...[
              SliverToBoxAdapter(
                  child: Container(
                      margin: const EdgeInsetsDirectional.all(10),
                      child: Column(children: [
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Price',
                                style: TextStyle(
                                  color: context.colorScheme.thirdText,
                                  fontSize: 14,
                                ),
                              ),
                              Row(mainAxisSize: MainAxisSize.max, children: [
                                Text(
                                  showReverse.value
                                      ? preOrderMeta.value?.reversePriceText ??
                                          ''
                                      : preOrderMeta.value?.priceText ?? '',
                                  style: TextStyle(
                                    color: context.colorScheme.thirdText,
                                    fontSize: 14,
                                  ),
                                ),
                                Container(width: 10),
                                InkResponse(
                                    radius: 14,
                                    child: SvgPicture.asset(
                                      R.resourcesSwapacrossSvg,
                                      height: 14,
                                      width: 14,
                                      color: context.colorScheme.thirdText,
                                    ),
                                    onTap: () {
                                      showReverse.value = !showReverse.value;
                                    }),
                              ])
                            ]),
                        Container(
                          height: 10,
                        ),
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Min Recevied',
                                style: TextStyle(
                                  color: context.colorScheme.thirdText,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                (preOrderMeta.value?.minReceivedText ?? '0') +
                                    ' ${outputAsset.asset.symbol}'.overflow,
                                style: TextStyle(
                                  color: context.colorScheme.thirdText,
                                  fontSize: 14,
                                ),
                              ),
                            ]),
                        Container(
                          height: 10,
                        ),
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Fee',
                                style: TextStyle(
                                  color: context.colorScheme.thirdText,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                (preOrderMeta.value?.feeText ?? '0') +
                                    ' ${inputAsset.asset.symbol}'.overflow,
                                style: TextStyle(
                                  color: context.colorScheme.thirdText,
                                  fontSize: 14,
                                ),
                              ),
                            ]),
                        Container(
                          height: 10,
                        ),
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Price Impact',
                                style: TextStyle(
                                  color: context.colorScheme.thirdText,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                preOrderMeta.value?.order.ctx.priceImpact
                                        .toPercentage ??
                                    '',
                                style: TextStyle(
                                  color: context.colorScheme.thirdText,
                                  fontSize: 14,
                                ),
                              ),
                            ]),
                        Container(
                          height: 10,
                        ),
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Route',
                                style: TextStyle(
                                  color: context.colorScheme.thirdText,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                preOrderMeta.value?.routes ?? '',
                                style: TextStyle(
                                  color: context.colorScheme.thirdText,
                                  fontSize: 14,
                                ),
                              ),
                            ]),
                      ]))),
            ],
            SliverToBoxAdapter(
                child: Container(
              height: 20,
            )),
            if (isLogin) ...[
              SliverToBoxAdapter(
                  child: Center(
                      child: SizedBox(
                width: 200,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    if (preOrderMeta.value != null) {
                      showDialogFunction();
                    } else {
                      showError('PreOrderMeta should not be null');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(
                          color: Color(0xFFcccccc),
                        )),
                  ),
                  child: const Text('Swap'),
                ),
              ))),
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
                      builder: (BuildContext context) => const Auth()),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(
                          color: Color(0xFFcccccc),
                        )),
                  ),
                  child: const Text('Connect Wallet'),
                ),
              ))),
            ],
            // SliverToBoxAdapter(
            //     child: Container(
            //   height: 40,
            // )),
            // SliverToBoxAdapter(
            //     child: Container(
            //   margin: const EdgeInsetsDirectional.all(10),
            //   child: const Text('Assets Pool'),
            // )),
            // SliverToBoxAdapter(
            //     child: Container(
            //         padding: const EdgeInsets.all(20.0),
            //         margin: const EdgeInsetsDirectional.all(10),
            //         decoration: const BoxDecoration(
            //           color: Color(0xFFcccccc),
            //           borderRadius: BorderRadius.all(Radius.circular(4.0)),
            //         ),
            //         child: Stack(children: <Widget>[
            //           Column(mainAxisSize: MainAxisSize.max, children: [
            //             InkWell(
            //               onTap: () {
            //                 onTap(assetList[0].asset.id);
            //               },
            //               child: Row(
            //                   mainAxisSize: MainAxisSize.max,
            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                   children: [
            //                     Expanded(
            //                         child: Row(
            //                             mainAxisSize: MainAxisSize.max,
            //                             children: [
            //                           SymbolIconWithBorder(
            //                             symbolUrl: assetList[0].asset.logo,
            //                             chainUrl: assetList[0].asset.chainLogo,
            //                             size: 24,
            //                             chainSize: 8,
            //                             chainBorder: BorderSide(
            //                               color: context.colorScheme.background,
            //                               width: 1.5,
            //                             ),
            //                           ),
            //                           const SizedBox(width: 12),
            //                           Text(
            //                             ' ${assetList[0].asset.symbol}'.overflow,
            //                             style: TextStyle(
            //                               color: context.colorScheme.primaryText,
            //                               fontSize: 14,
            //                               fontWeight: FontWeight.w400,
            //                             ),
            //                           ),
            //                         ])),
            //                     Expanded(
            //                         child: Row(
            //                             mainAxisSize: MainAxisSize.max,
            //                             mainAxisAlignment: MainAxisAlignment.end,
            //                             children: [
            //                           Text(
            //                             ' ${assetList[0].asset.price.toFiat()}',
            //                             style: TextStyle(
            //                               color: context.colorScheme.primaryText,
            //                               fontSize: 14,
            //                               fontWeight: FontWeight.w400,
            //                             ),
            //                           ),
            //                           InkResponse(
            //                               radius: 24,
            //                               child: SvgPicture.asset(
            //                                 R.resourcesRightSvg,
            //                                 height: 18,
            //                                 width: 18,
            //                                 color:
            //                                     context.colorScheme.primaryText,
            //                               ),
            //                               onTap: () => i('>>>>>>>tip')),
            //                         ]))
            //                   ]),
            //             ),
            //             Container(
            //               height: 20,
            //             ),
            //             InkWell(
            //               onTap: () {
            //                 onTap(assetList[1].asset.id);
            //               },
            //               child: Row(
            //                   mainAxisSize: MainAxisSize.max,
            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                   children: [
            //                     Expanded(
            //                         child: Row(
            //                             mainAxisSize: MainAxisSize.max,
            //                             children: [
            //                           SymbolIconWithBorder(
            //                             symbolUrl: assetList[1].asset.logo,
            //                             chainUrl: assetList[1].asset.chainLogo,
            //                             size: 24,
            //                             chainSize: 8,
            //                             chainBorder: BorderSide(
            //                               color: context.colorScheme.background,
            //                               width: 1.5,
            //                             ),
            //                           ),
            //                           const SizedBox(width: 12),
            //                           Text(
            //                             ' ${assetList[1].asset.symbol}'.overflow,
            //                             style: TextStyle(
            //                               color: context.colorScheme.primaryText,
            //                               fontSize: 14,
            //                               fontWeight: FontWeight.w400,
            //                             ),
            //                           ),
            //                         ])),
            //                     Expanded(
            //                         child: Row(
            //                             mainAxisSize: MainAxisSize.max,
            //                             mainAxisAlignment: MainAxisAlignment.end,
            //                             children: [
            //                           Text(
            //                             ' ${assetList[1].asset.price.toFiat()}',
            //                             style: TextStyle(
            //                               color: context.colorScheme.primaryText,
            //                               fontSize: 14,
            //                               fontWeight: FontWeight.w400,
            //                             ),
            //                           ),
            //                           InkResponse(
            //                               radius: 24,
            //                               child: SvgPicture.asset(
            //                                 R.resourcesRightSvg,
            //                                 height: 18,
            //                                 width: 18,
            //                                 color:
            //                                     context.colorScheme.primaryText,
            //                               ),
            //                               onTap: () => i('>>>>>>>tip')),
            //                         ]))
            //                   ]),
            //             ),
            //             Container(
            //               height: 20,
            //             ),
            //             Container(
            //               height: 1,
            //               color: const Color(0xFFbbbbbb),
            //             ),
            //             Container(
            //               height: 20,
            //             ),
            //             Row(
            //                 mainAxisSize: MainAxisSize.max,
            //                 mainAxisAlignment: MainAxisAlignment.center,
            //                 children: [
            //                   InkResponse(
            //                       radius: 24,
            //                       child: SvgPicture.asset(
            //                         R.resourcesUprightSvg,
            //                         height: 20,
            //                         width: 20,
            //                         color: context.colorScheme.primaryText,
            //                       )),
            //                   const Text('Pool Details'),
            //                 ]),
            //           ]),
            //         ]))),
          ],
        ),
      ),
    );
  }
}
