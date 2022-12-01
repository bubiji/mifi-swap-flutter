import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
// import '../../util/hook.dart';
// import '../../util/logger.dart';
// import '../widget/account.dart';
// import '../widget/dialog_builder.dart';
import '../widget/symbol.dart';
import 'home/empty.dart';

class SearchAsset extends HookWidget {
  const SearchAsset({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assetList = useState<List<sdk.Asset>>([]);
    final chains = useState<Map<String, String>>({});
    final addedAssetIdList = useState<List<String>>(dbMyAssetIdList);

    final timer = useState<Timer?>(null);

    void handleSearch(String query) {
      timer.value?.cancel();

      timer.value = Timer(const Duration(milliseconds: 150), () async {
        final keystore = await getKeyStore();
        if (keystore == null) {
          return;
        }
        final bot = context.appServices.getClientWithKeyStore(keystore);
        final rsp = await bot.assetApi.queryAsset(query);

        final assets = rsp.data;

        final chains0 = chains.value;
        for (final asset in assets) {
          if ((chains0[asset.chainId] ?? '').isEmpty) {
            final rsp = await bot.assetApi.getAssetById(asset.chainId);
            final chain = rsp.data;
            chains0[chain.assetId] = chain.iconUrl;
          }
        }

        assetList.value = assets;
        chains.value = chains0;

        if (addedAssetIdList.value.length <= dbMyAssetIdList.length) {
          final rsp = await bot.assetApi.getAssets();
          final myAssets = rsp.data;
          final assetIdList = [...addedAssetIdList.value];

          for (final asset in myAssets) {
            if (!assetIdList.contains(asset.assetId)) {
              assetIdList.add(asset.assetId);
            }
          }
          addedAssetIdList.value = assetIdList;
        }
      });
    }

    Future<void> handleAddAsset(sdk.Asset asset) async {
      addedAssetIdList.value = [asset.assetId, ...addedAssetIdList.value];
      await setDbMyAssetIdList([asset.assetId, ...dbMyAssetIdList]);
    }

    return Scaffold(
      backgroundColor: context.theme.background,
      appBar: AppBar(title: const Text('Add Asset')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ListTile(
              title: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Keyword',
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: handleSearch,
              ),
            ),
          ),
          _AssetsSliverList(
            assetList: assetList.value,
            chains: chains.value,
            addedAssetIdList: addedAssetIdList.value,
            onAdd: handleAddAsset,
          ),
        ],
      ),
    );
  }
}

class _AssetsSliverList extends StatelessWidget {
  const _AssetsSliverList({
    Key? key,
    required this.assetList,
    required this.chains,
    required this.addedAssetIdList,
    required this.onAdd,
  }) : super(key: key);

  final List<sdk.Asset> assetList;
  final Map<String, String> chains;
  final List<String> addedAssetIdList;
  final void Function(sdk.Asset) onAdd;

  @override
  Widget build(BuildContext context) {
    if (assetList.isEmpty) {
      return SliverFillRemaining(
        child: EmptyLayout(content: context.l10n.noAsset),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final item = assetList[index];
          return _AssetWidget(
            data: item,
            chainUrl: chains[item.chainId],
            isAdded: addedAssetIdList.contains(item.assetId),
            onAdd: () => onAdd(item),
          );
        },
        childCount: assetList.length,
      ),
    );
  }
}

class _AssetWidget extends StatelessWidget {
  const _AssetWidget({
    Key? key,
    required this.data,
    this.chainUrl,
    required this.isAdded,
    required this.onAdd,
  }) : super(key: key);

  final sdk.Asset data;
  final String? chainUrl;
  final bool isAdded;
  final void Function() onAdd;

  @override
  Widget build(BuildContext context) => Container(
        height: 80,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SymbolIconWithBorder(
              symbolUrl: data.iconUrl,
              chainUrl: chainUrl,
              size: 40,
              chainSize: 14,
              chainBorder: BorderSide(
                color: context.colorScheme.background,
                width: 1.5,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Text(
                        ' ${data.symbol}'.overflow,
                        style: TextStyle(
                          color: context.colorScheme.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    data.name,
                    style: TextStyle(
                      color: context.colorScheme.thirdText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isAdded)
              const IconButton(
                onPressed: null,
                icon: Icon(Icons.done, color: Colors.green),
              )
            else
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add, color: Colors.grey),
              ),
          ],
        ),
      );
}
