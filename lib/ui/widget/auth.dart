import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/logger.dart';
import '../../util/r.dart';

class Auth extends HookWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loading = useState(false);
    final codeUrl = useState('');

    useMemoizedFuture(() async {
      var launched = false;
      context.appServices.connect((url, oauthCode) {
        codeUrl.value = url ?? '';
        if (oauthCode?.isEmpty ?? true) {
          if (!launched && url != null) {
            scheduleMicrotask(() async {
              launched = true;
              final parsedUrl = Uri.parse(url);
              if (!await launchUrl(parsedUrl)) {
                launched = false;
              }
            });
          }
          return false;
        }
        loading.value = true;
        scheduleMicrotask(() async {
          try {
            await context.appServices.login(oauthCode ?? '');
            Navigator.pop(context);
            isAuthChange.value = !isAuthChange.value;
          } catch (error, s) {
            e('$error, $s');
            loading.value = false;
          }
        });
        return true;
      });
    });

    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child:
              loading.value ? _ProgressBody() : _AuthBody(url: codeUrl.value),
        ),
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(
            height: 30,
          ),
          Text(context.l10n.authTips),
        ],
      );
}

class _AuthBody extends StatelessWidget {
  const _AuthBody({
    Key? key,
    required this.url,
  }) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) => Column(
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
                if (url.isNotEmpty)
                  Center(
                    child: QrImage(
                      data: url,
                      version: QrVersions.auto,
                      size: 250.0,
                      embeddedImage: const AssetImage(R.resourcesMixinLogoPng),
                    ),
                  )
                else
                  Container(),
              ],
            ),
          ),
        ],
      );
}
