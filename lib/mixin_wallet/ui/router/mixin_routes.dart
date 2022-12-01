import 'package:flutter/widgets.dart';
import 'package:vrouter/vrouter.dart';

import '../page/all_transactions.dart';
import '../page/asset_deposit.dart';
import '../page/asset_detail.dart';
import '../page/hidden_assets.dart';
import '../page/not_found.dart';
import '../page/setting.dart';
import '../page/snapshot_detail.dart';
import '../page/withdrawal.dart';
import '../page/withdrawal_transactions.dart';

final homeUri = Uri(path: '/me');
final notFoundUri = Uri(path: '/404-1');
const withdrawalPath = '/withdrawal/:id';
const withdrawalTransactionsPath = '/withdrawal/:id/transactions';
const assetDetailPath = '/tokens/:id';
const assetDepositPath = '/tokens/:id/deposit';
const snapshotDetailPath = '/snapshots/:id';
final transactionsUri = Uri(path: '/transactions');
const transactionsSnapshotDetailPath = '/transactions/snapshots/:id';
final hiddenAssetsUri = Uri(path: '/hiddenAssets');
const settingPath = '/setting';
const swapPath = '/swap';

List<VRouteElementBuilder> buildMixinRoutes(BuildContext context) => [
      VWidget(
        key: const ValueKey('Withdrawal'),
        path: withdrawalPath,
        widget: const Withdrawal(),
        stackedRoutes: [
          VWidget(
            key: const ValueKey('WithdrawalTransactions'),
            path: withdrawalTransactionsPath,
            widget: const WithdrawalTransactions(),
          )
        ],
      ),
      VWidget(
        key: const ValueKey('AssetDetail'),
        path: assetDetailPath,
        widget: const AssetDetail(),
        stackedRoutes: [
          VWidget(
            key: const ValueKey('SnapshotDetail'),
            path: snapshotDetailPath,
            widget: const SnapshotDetail(),
          ),
        ],
      ),
      VWidget(
        key: const ValueKey('AssetDeposit'),
        path: assetDepositPath,
        widget: const AssetDeposit(),
      ),
      VWidget(
        key: const ValueKey('NotFound'),
        path: notFoundUri.toString(),
        widget: const NotFound(),
      ),
      VWidget(
        key: const ValueKey('Setting'),
        path: settingPath,
        widget: const Setting(),
        stackedRoutes: [
          VWidget(
            key: const ValueKey('Transactions'),
            path: transactionsUri.toString(),
            widget: const AllTransactions(),
            stackedRoutes: [
              VWidget(
                key: const ValueKey('TransactionsSnapshotDetail'),
                path: transactionsSnapshotDetailPath,
                widget: const SnapshotDetail(),
              ),
            ],
          ),
          VWidget(
            key: const ValueKey('HiddenAssets'),
            path: hiddenAssetsUri.toString(),
            widget: const HiddenAssets(),
          ),
        ],
      ),
    ];
