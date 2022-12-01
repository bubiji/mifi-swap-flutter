import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../util/extension/extension.dart';
import '../../../util/r.dart';
import '../../../util/swap_pair.dart';
import '../../router/mixin_routes.dart';

class Wallent_Header extends HookWidget {
  const Wallent_Header({
    Key? key,
    required this.overview,
  }) : super(key: key);

  final SwapPairOverview overview;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            overviewSection(context, context.l10n.overview),
            const SizedBox(height: 4),
            titleSection(overview.volume24h.toFiat),
            buttonSection,
            const SizedBox(height: 10),
          ],
        ),
      );
}

//over section
Widget overviewSection(BuildContext context, String text) => Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        InkResponse(
          radius: 24,
          onTap: () => context.push(overviewPath),
          child: SvgPicture.asset(R.resourcesUprightSvg,
              height: 24,
              width: 24,
              color: Colors.blue // context.colorScheme.primaryText,
              ),
        ),
      ],
    );

//title section
Widget titleSection(String title) => Container(
      // padding: const EdgeInsets.all(20.0),
      // margin: const EdgeInsetsDirectional.only(top: 20),
      // decoration: const BoxDecoration(
      //   color: Color(0xFF5A70B9),
      //   borderRadius: BorderRadius.all(Radius.circular(8.0)),
      // ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: Column(mainAxisSize: MainAxisSize.max, children: [
            Center(
              child: Text('余额：$title',
                  style: const TextStyle(
                    //color: context.colorScheme.thirdText,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  )),
            ),
          ])),
        ],
      ),
    );

// buttons section
Widget buttonSection = Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    _buildButtonColumn(R.resourcesArrowUpCircleSvg, 'Receive'),
    _buildButtonColumn(R.resourcesDirectionDownCircleSvg, 'Send'),
  ],
);

// define button
Column _buildButtonColumn(String iconString, String label) => Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: SvgPicture.asset(
            iconString,
            color: Colors.blue,
          ),
          onPressed: () {
            print(iconString);
          },
          iconSize: 60,
          //tooltip: "Bus Direction",
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.black, fontSize: 15),
              )
            ],
          )
        ])
      ],
    );
