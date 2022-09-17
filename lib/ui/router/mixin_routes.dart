import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vrouter/vrouter.dart';

import '../../util/extension/extension.dart';
import '../../util/r.dart';
import '../page/asset_detail.dart';
import '../page/home.dart';
import '../page/not_found.dart';
import '../page/overview.dart';
import '../page/search.dart';
import '../page/swap.dart';

final homeUri = Uri(path: '/');
final notFoundUri = Uri(path: '/404');
const assetDetailPath = '/asset/detail/:id';
const swapPath = '/swap';
const overviewPath = '/overview';
final searchUri = Uri(path: '/search');

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
                      key: const ValueKey('Home'),
                      path: homeUri.toString(),
                      widget: const Home(),
                      stackedRoutes: [
                        VWidget(
                          key: const ValueKey('AssetDetail'),
                          path: assetDetailPath,
                          widget: const AssetDetail(),
                        ),
                        VWidget(
                          key: const ValueKey('NotFound'),
                          path: notFoundUri.toString(),
                          widget: const NotFound(),
                        ),
                        VWidget(
                          key: const ValueKey('Swap'),
                          path: swapPath,
                          widget: const Swap(),
                        ),
                        VWidget(
                          key: const ValueKey('Overview'),
                          path: overviewPath,
                          widget: const Overview(),
                        ),
                        VWidget(
                          key: const ValueKey('Search'),
                          path: searchUri.toString(),
                          widget: const Search(),
                        ),
                      ]),
                ]),
          ]),
      VRouteRedirector(path: ':_(.+)', redirectTo: '/404'),
    ];

class AppTabsScaffold extends StatelessWidget {
  const AppTabsScaffold({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final currentIndex = context.vRouter.url.contains('swap') ? 1 : 0;
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
                currentIndex: currentIndex,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      return context.vRouter.to('/');
                    case 1:
                      return context.vRouter.to('/swap');
                  }
                },
                items: [
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      R.resourcesHomeSvg,
                      height: 24,
                      width: 24,
                      color: context.colorScheme.primaryText,
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      R.resourcesSwapSvg,
                      height: 24,
                      width: 24,
                      color: context.colorScheme.primaryText,
                    ),
                    label: 'Swap',
                  ),
                ]),
          ],
        ),
      ),
    );
  }
}
