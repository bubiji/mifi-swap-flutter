import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import './auth.dart';
import '../../util/extension/extension.dart';
import '../../util/r.dart';
import '../widget/mixin_bottom_sheet.dart';

class ConnectWallet extends HookWidget {
  const ConnectWallet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
        height: MediaQuery.of(context).size.height - 280,
        child: const Center(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: _Body(),
          ),
        ),
      );
}

class _Body extends StatelessWidget {
  const _Body({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Stack(
              children: [
                Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(context.l10n.connectWallet,
                              style: TextStyle(
                                color: context.colorScheme.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ))),
                      InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(context.l10n.cancel,
                                  style: TextStyle(
                                    color: context.colorScheme.primaryText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  )))),
                    ])
              ],
            ),
          ),
          const SizedBox(height: 4),
          InkResponse(
              onTap: () {
                Navigator.pop(context);
                showMixinBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) => const Auth());
              },
              child: Container(
                  padding: const EdgeInsets.all(20.0),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFcccccc),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.max, children: [
                    Image.asset(
                      R.resourcesMixinLogoPng,
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 30),
                    const Text('Mixin Messenger')
                  ]))),
          const SizedBox(height: 4),
          Container(
              padding: const EdgeInsets.all(20.0),
              child: Row(mainAxisSize: MainAxisSize.max, children: [
                Expanded(
                    child: Text(context.l10n.connectinfo +
                        context.l10n.termsOfService +
                        context.l10n.and +
                        context.l10n.privaryPolicy)),
              ])),
        ],
      );
}
