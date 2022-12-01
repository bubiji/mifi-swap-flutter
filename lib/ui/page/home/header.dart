import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../util/extension/extension.dart';
import '../../../util/r.dart';
import '../../../util/swap_pair.dart';
import '../../router/mixin_routes.dart';

class Header extends HookWidget {
  const Header({
    Key? key,
    required this.overview,
  }) : super(key: key);

  final SwapPairOverview overview;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Text(
                    context.l10n.overview,
                    style: const TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
                InkResponse(
                  radius: 24,
                  onTap: () => context.push(overviewPath),
                  child: SvgPicture.asset(
                    R.resourcesUprightSvg,
                    height: 24,
                    width: 24,
                    color: context.colorScheme.primaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(20.0),
              margin: const EdgeInsetsDirectional.only(top: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF5A70B9),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                      child: Column(mainAxisSize: MainAxisSize.max, children: [
                    Text(
                      context.l10n.totalLiquidity,
                      style: const TextStyle(color: Color(0xFFff6bc0)),
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
                                style: TextStyle(
                                  color: context.colorScheme.thirdText,
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
                      style: const TextStyle(color: Color(0xFFff6bc0)),
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
                                style: TextStyle(
                                  color: context.colorScheme.thirdText,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ])),
                  ])),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
}
