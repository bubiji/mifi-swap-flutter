import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:vrouter/vrouter.dart';

// import 'mixin_wallet/ui/router/mixin_routes.dart' as mixin_wallet;
import 'service/app_services.dart';
import 'service/profile/profile_manager.dart';
import 'ui/brightness_theme_data.dart';
import 'ui/models/m_swap_assetmeta_CartModel.dart';
import 'ui/router/mixin_routes.dart';
import 'ui/widget/brightness_observer.dart';
import 'util/l10n.dart';
import 'util/logger.dart';
import 'util/mixin_context.dart';
import 'util/web/web_utils_dummy.dart'
    if (dart.library.html) 'util/web/web_utils.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initStorage();

  final mixinLocale = getMixinLocale();
  i('mixinLocale: $mixinLocale');
  if (mixinLocale != null) {
    await L10n.delegate.load(mixinLocale);
  }

  runZonedGuarded(
    () => runApp(MyApp()),
    (Object error, StackTrace stack) {
      if (!kLogMode) return;
      e('$error, $stack');
    },
    zoneSpecification: ZoneSpecification(
      handleUncaughtError: (_, __, ___, Object error, StackTrace stack) {
        if (!kLogMode) return;
        wtf('$error, $stack');
      },
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        if (!kLogMode) return;
        parent.print(zone, colorizeNonAnsi(line));
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final vRouterStateKey = GlobalKey<VRouterState>();

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider(create: (context) => SwapAssetListModel()),
          ChangeNotifierProxyProvider<SwapAssetListModel,
              MySwapAsset_CartModel>(
            create: (context) => MySwapAsset_CartModel(),
            update: (context, catalog, cart) {
              if (cart == null) throw ArgumentError.notNull('cart');
              cart.catalog = catalog;
              return cart;
            },
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => AppServices(
              vRouterStateKey: vRouterStateKey,
            ),
          ),
        ],
        child: _Router(vRouterStateKey: vRouterStateKey),
      );
}

class _Router extends StatelessWidget {
  const _Router({
    required this.vRouterStateKey,
    Key? key,
  }) : super(key: key);

  final GlobalKey<VRouterState> vRouterStateKey;

  @override
  Widget build(BuildContext context) => VRouter(
      key: vRouterStateKey,
      title: '4sawp',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        ...L10n.delegate.supportedLocales,
      ],
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: _NoAnimationPageTransitionsBuilder(),
            TargetPlatform.android: _NoAnimationPageTransitionsBuilder(),
          },
        ),
        fontFamily: getFallbackFontFamily(),
      ),
      builder: (BuildContext context, Widget child) => DefaultTextStyle(
            style: TextStyle(
              height: 1,
              // Add underline decoration for Safari.
              // https://github.com/flutter/flutter/issues/90705#issuecomment-927944039
              // because Chinese/Japanese characters can not render in latest safari(iOS15).
              decoration: defaultTargetPlatform == TargetPlatform.iOS ||
                      defaultTargetPlatform == TargetPlatform.macOS
                  ? TextDecoration.underline
                  : null,
            ),
            child: BrightnessObserver(
              lightThemeData: lightBrightnessThemeData,
              child: child,
            ),
          ),
      routes:
          buildMixinRoutes(context) //+ mixin_wallet.buildMixinRoutes(context),
      );
}

class _NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoAnimationPageTransitionsBuilder() : super();

  @override
  Widget buildTransitions<T>(
          PageRoute<T> route,
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child) =>
      child;
}
