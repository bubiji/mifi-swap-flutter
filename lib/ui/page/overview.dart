import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/swap_pair.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';

class Overview extends HookWidget {
  const Overview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final swapPairResults = useMemoizedStream(
      () => context.appServices.mixinDatabase.swapPairDao.getAll().watch(),
      initialData: <SwapPair>[],
    ).requireData;

    final overview = useMemoized(() {
      final overview = SwapPairOverview();
      swapPairResults.forEach(overview.plus);
      return overview;
    }, [swapPairResults]);
    return Scaffold(
      appBar: MixinAppBar(
        leading: const MixinBackHomeButton(),
        title: SelectableText(
          context.l10n.overview,
          style: TextStyle(
            color: context.colorScheme.primaryText,
            fontSize: 18,
          ),
          enableInteractiveSelection: false,
        ),
        backgroundColor: context.colorScheme.background,
      ),
      backgroundColor: context.theme.background,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                  child: Column(mainAxisSize: MainAxisSize.max, children: [
                Text(
                  context.l10n.totalLiquidity,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: context.colorScheme.thirdText),
                ),
                Container(
                    margin: const EdgeInsetsDirectional.only(top: 20),
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            overview.totalUSDValue.toFiat,
                            style: const TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ])),
              ])),
              Expanded(
                  child: Column(mainAxisSize: MainAxisSize.max, children: [
                Text(
                  context.l10n.globalVol,
                  style: TextStyle(color: context.colorScheme.thirdText),
                ),
                Container(
                    margin: const EdgeInsetsDirectional.only(top: 20),
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            overview.volume24h.toFiat,
                            style: const TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ])),
              ])),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                  child: Column(mainAxisSize: MainAxisSize.max, children: [
                Text(
                  context.l10n.trades,
                  style: TextStyle(color: context.colorScheme.thirdText),
                ),
                Container(
                    margin: const EdgeInsetsDirectional.only(top: 20),
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            overview.transactions.toString(),
                            style: const TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ])),
              ])),
              Expanded(
                  child: Column(mainAxisSize: MainAxisSize.max, children: [
                Text(
                  context.l10n.fees,
                  style: TextStyle(color: context.colorScheme.thirdText),
                ),
                Container(
                    margin: const EdgeInsetsDirectional.only(top: 20),
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            overview.fee24h.toFiat,
                            style: const TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ])),
              ])),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                  child: Column(mainAxisSize: MainAxisSize.max, children: [
                Text(
                  context.l10n.turnover,
                  style: TextStyle(color: context.colorScheme.thirdText),
                ),
                Container(
                    margin: const EdgeInsetsDirectional.only(top: 20),
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            overview.turnOver.toPercentage,
                            style: const TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ])),
              ])),
              Expanded(
                child: Container(
                  margin: const EdgeInsetsDirectional.only(top: 20),
                ),
              ),
            ]),
            const SizedBox(height: 8),
          ]),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 10,
            color: const Color(0xFFF6F7FA),
          ),
        ),
      ]),
    );
  }
}
