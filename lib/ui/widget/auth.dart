import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/logger.dart';
import '../../util/r.dart';

class Auth extends HookWidget {
  const Auth({Key? key, this.bind = false}) : super(key: key);

  final bool bind;

  @override
  Widget build(BuildContext context) {
    final loading = useState(false);
    final codeUrl = useState('');

    useEffect(() {
      var running = true;
      final scope = bind ? 'PROFILE:READ' : 'PROFILE:READ ASSETS:READ';
      context.appServices.connect(scope, (url, oauthCode) {
        if (!running) {
          return true;
        }
        codeUrl.value = url ?? '';
        if (oauthCode?.isEmpty ?? true) {
          return false;
        }
        loading.value = true;
        scheduleMicrotask(() async {
          try {
            if (bind) {
              await context.appServices.bindMixinUser(oauthCode ?? '');
              // } else {
              // await context.appServices.login(oauthCode ?? '');
              // isAuthChange.value = !isAuthChange.value;
            }
            Navigator.pop(context);
          } catch (error, s) {
            e('$error, $s');
            loading.value = false;
          }
        });
        return true;
      });
      return () {
        running = false;
      };
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mixin Binding'),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height - 300,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child:
                loading.value ? _ProgressBody() : _AuthBody(url: codeUrl.value),
          ),
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
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final parsedUrl = Uri.parse(url);
              launchUrl(parsedUrl);
            },
            child: const Text(
              'Open Mixin',
            ),
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
            ),
          ),
        ],
      );
}
