import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../util/extension/extension.dart';
import '../../util/logger.dart';
import '../../util/r.dart';
import '../widget/symbol.dart';

Future<void> showSwapSuccess(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (context) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop(true);
      });
      return AlertDialog(
        title: Text(
          context.l10n.success,
          textAlign: TextAlign.center,
        ),
        titlePadding: const EdgeInsets.all(20),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 16),
        content: Text(context.l10n.swapSuccessfully),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20.0),
        contentTextStyle: const TextStyle(color: Colors.black54, fontSize: 14),
      );
    },
  );
}

Future<void> checkSwapResult(BuildContext context, String followId) async {
  const timeout = Duration(seconds: 1);
  final done = Completer<void>();

  var count = 0;

  final timer = Timer.periodic(timeout, (timer) async {
    count += 1;
    if (count > 5) {
      done.complete();
    }
    //1s 回调一次
    try {
      final rsp = await context.appServices.fswap.readOrderDetail(followId);
      i('$rsp');
      done.complete();
    } catch (error, s) {
      e('$error, $s');
    }
  });
  await done.future;
  timer.cancel();
  await showSwapSuccess(context);
}

class SwapCode extends HookWidget {
  const SwapCode(
      {Key? key,
      required this.codeUrl,
      required this.inputString,
      required this.followId,
      required this.logo,
      required this.chainLogo})
      : super(key: key);

  final String codeUrl;
  final String inputString;
  final String followId;
  final String logo;
  final String chainLogo;

  @override
  Widget build(BuildContext context) {
    final loading = useState(false);

    Future<void> handleSwap() async {
      if (loading.value) {
        return;
      }
      loading.value = true;
      await checkSwapResult(context, followId);
      Navigator.pop(context);
    }

    return SizedBox(
        height: MediaQuery.of(context).size.height - 100,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: Opacity(
                          opacity: 0.9,
                          child: Image.asset(
                            R.resourcesAuthBgWebp,
                            fit: BoxFit.cover,
                            height: 360,
                            width: 360,
                          ),
                        ),
                      ),
                      if (codeUrl.isNotEmpty)
                        Center(
                          child: QrImage(
                            data: codeUrl,
                            version: QrVersions.auto,
                            size: 250.0,
                            embeddedImage:
                                const AssetImage(R.resourcesLogoWebp),
                          ),
                        )
                      else
                        Container(),
                    ],
                  ),
                ),
                Expanded(
                    child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20.0),
                        decoration: const BoxDecoration(
                          color: Color(0xFF000000),
                        ),
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SymbolIconWithBorder(
                                symbolUrl: logo,
                                chainUrl: chainLogo,
                                size: 50,
                                chainSize: 15,
                                chainBorder: BorderSide(
                                  color: context.colorScheme.background,
                                  width: 1.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(context.l10n.scanTopay,
                                  style: const TextStyle(
                                    color: Color(0xFFffffff),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  )),
                              Text(
                                inputString,
                                style: const TextStyle(
                                  color: Color(0xFFffffff),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(context.l10n.scanandpay,
                                  style: const TextStyle(
                                    color: Color(0xFFffffff),
                                  )),
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: handleSwap,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(20),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: const BorderSide(
                                        color: Color(0xFFffffff),
                                      )),
                                ),
                                child: Text(
                                    loading.value
                                        ? context.l10n.transactionChecking
                                        : context.l10n.paid,
                                    style: const TextStyle(
                                      color: Color(0xFFffffff),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ),
                            ])))
              ],
            ),
          ),
        ));
  }
}
