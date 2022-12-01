import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vrouter/vrouter.dart';

import '../../mixin_wallet/ui/router/mixin_routes.dart' as mixin_wallet;
import '../../util/extension/extension.dart';
import '../../util/r.dart';
// import '../page/home.dart';
import '../page/not_found.dart';
import '../page/overview.dart';
import '../page/search_add.dart';
import '../page/swap.dart';
import '../page/swap_asset_detail.dart';
import '../page/wallet.dart';

final homeUri = Uri(path: '/');
final notFoundUri = Uri(path: '/404');
const swapAssetDetailPath = '/swapAsset/detail/:id';
const swapPath = '/swap';
const overviewPath = '/overview';
final searchUri = Uri(path: '/search');
final meUri = Uri(path: '/me');

List<VRouteElementBuilder> buildMixinRoutes(BuildContext context) => [
      VNester(
        path: null,
        widgetBuilder: (child) => AppTabsScaffold(child: child),
        nestedRoutes: [
          VGuard(
            beforeEnter: (redirector) async {
              await context.appServices.initServiceFuture;
              FlutterNativeSplash.remove();
              return;
            },
            stackedRoutes: [
              VWidget(
                key: const ValueKey('NotFound'),
                path: notFoundUri.toString(),
                widget: const NotFound(),
              ),
              VWidget(
                key: const ValueKey('Me'),
                path: meUri.toString(),
                widget: const Wallet(),
                stackedRoutes: [
                  ...mixin_wallet.buildMixinRoutes(context),
                ],
              ),
              VWidget(
                key: const ValueKey('Swap'),
                path: swapPath,
                widget: const Swap(),
                buildTransition: (animation1, _, child) =>
                    ScaleTransition(scale: animation1, child: child),
              ),
              VWidget(
                key: const ValueKey('Home'),
                path: homeUri.toString(),
                widget: const Swap(),
                stackedRoutes: [
                  VWidget(
                    key: const ValueKey('SwapAssetDetail'),
                    path: swapAssetDetailPath,
                    widget: const SwapAssetDetail(),
                  ),
                  VWidget(
                    key: const ValueKey('Overview'),
                    path: overviewPath,
                    widget: const Overview(),
                  ),
                  VWidget(
                    key: const ValueKey('Search'),
                    path: searchUri.toString(),
                    widget: const Search_Add(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // VRouteRedirector(path: ':_(.+)', redirectTo: '/404'),
      VRouteRedirector(path: ':_(.+)', redirectTo: '/404-1'),
    ];

class AppTabsScaffold extends StatelessWidget {
  const AppTabsScaffold({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    int getCurrentIndex() {
      final url = context.vRouter.url;
      if (url == '/') {
        return 0;
      }
      if (url.contains('swap')) {
        return 0;
      }
      if (url.startsWith('/?')) {
        return 0;
      }
      if (url.contains('me')) {
        return 1;
      }
      if (url.contains('mixin_wallet')) {
        return 1;
      }
      return 1;
    }

    return Scaffold(
      body: SafeArea(
        top: false,
        child: child,
      ),
      bottomNavigationBar: Material(
        elevation: 8.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: getCurrentIndex(),
                onTap: (index) {
                  switch (index) {
                    case 0:
                      return context.vRouter.to('/');
                    case 1:
                      return context.vRouter.to('/me');
                  }
                },
                items: [
                  BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        R.resourcesSpinSvg,
                        height: 24,
                        width: 24,
                      ),
                      label: context.l10n.swap,
                      activeIcon: SvgPicture.asset(
                        R.resourcesSpinSvg,
                        height: 24,
                        width: 24,
                        color: Colors.blue,
                      )),
                  BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        R.resourcesWalletSvg,
                        height: 24,
                        width: 24,
                      ),
                      label: context.l10n.myWallet,
                      activeIcon: SvgPicture.asset(
                        R.resourcesWalletSvg,
                        height: 24,
                        width: 24,
                        color: Colors.blue,
                      )),
                ]),
          ],
        ),
      ),
    );
  }
}
