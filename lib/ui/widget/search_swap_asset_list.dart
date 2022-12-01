import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rxdart/rxdart.dart';

import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/r.dart';
import '../../util/swap_asset.dart';
import '../page/home/empty.dart';
import 'search_header_widget.dart';
import 'symbol.dart';

class SearchSwapAssetList extends HookWidget {
  const SearchSwapAssetList(
      {Key? key, required this.swapAssetList, required this.notifier})
      : super(key: key);
  final List<SwapAssetMeta> swapAssetList;
  final ValueNotifier<String> notifier;

  @override
  Widget build(BuildContext context) {
    final keywordStreamController = useStreamController<String>();
    final keywordStream = useMemoized(
        () => keywordStreamController.stream.map((e) => e.trim()).distinct());
    final hasKeyword =
        useMemoizedStream(() => keywordStream.map((event) => event.isNotEmpty))
                .data ??
            false;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 360,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 8),
              child: SearchHeaderWidget(
                hintText: context.l10n.search,
                onChanged: keywordStreamController.add,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: IndexedStack(
                index: hasKeyword ? 1 : 0,
                children: [
                  _EmptyKeywordSwapAssetList(
                      swapAssetList: swapAssetList, notifier: notifier),
                  _SearchSwapAssetList(
                      keywordStream: keywordStream,
                      notifier: notifier,
                      swapAssetList: swapAssetList),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyKeywordSwapAssetList extends HookWidget {
  const _EmptyKeywordSwapAssetList(
      {Key? key, required this.swapAssetList, required this.notifier})
      : super(key: key);
  final List<SwapAssetMeta> swapAssetList;
  final ValueNotifier<String> notifier;

  @override
  Widget build(BuildContext context) {
    if (swapAssetList.isEmpty) {
      return SliverFillRemaining(
        child: EmptyLayout(content: context.l10n.noAsset),
      );
    }

    final slivers = [
      if (swapAssetList.isNotEmpty)
        SliverToBoxAdapter(child: _SubTitle(context.l10n.assetTrending)),
      if (swapAssetList.isNotEmpty)
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) =>
                _Item(data: swapAssetList[index], notifier: notifier),
            childCount: swapAssetList.length,
          ),
        ),
    ];

    if (slivers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return CustomScrollView(
      slivers: slivers,
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle(
    this.title, {
    Key? key,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      );
}

class _SearchSwapAssetList extends HookWidget {
  const _SearchSwapAssetList({
    Key? key,
    required this.keywordStream,
    required this.notifier,
    required this.swapAssetList,
  }) : super(key: key);

  final Stream<String> keywordStream;
  final ValueNotifier<String> notifier;
  final List<SwapAssetMeta> swapAssetList;

  @override
  Widget build(BuildContext context) {
    final keyword = useMemoizedStream(() => keywordStream.throttleTime(
          const Duration(milliseconds: 100),
          trailing: true,
          leading: false,
        )).data;

    final searchList = useMemoized(
        () => swapAssetList.where((swapAsset) {
              final symbol =
                  (swapAsset.swapAsset.symbol ?? '').trim().toUpperCase();
              final k = (keyword ?? '').toUpperCase();

              return symbol.contains(k);
            }).toList(),
        [keyword]);

    if (searchList.isEmpty) {
      return const _SearchEmptyLayout();
    }

    return ListView.builder(
      itemCount: searchList.length,
      itemBuilder: (BuildContext context, int index) =>
          _Item(data: searchList[index], notifier: notifier),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({Key? key, required this.data, required this.notifier})
      : super(key: key);

  final SwapAssetMeta data;
  final ValueNotifier<String> notifier;

  @override
  Widget build(BuildContext context) {
    void onTap() {
      notifier.value = data.swapAsset.id;
      Navigator.pop(context);
    }

    return Material(
        color: context.theme.background,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: 20),
                SymbolIconWithBorder(
                  symbolUrl: data.swapAsset.logo,
                  chainUrl: data.swapAsset.chainLogo,
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
                      SelectableText(
                        ' ${data.swapAsset.symbol}'.overflow,
                        style: TextStyle(
                          color: context.theme.text,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                        onTap: onTap,
                        enableInteractiveSelection: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class _SearchEmptyLayout extends StatelessWidget {
  const _SearchEmptyLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 100),
          Center(
            child: SvgPicture.asset(
              R.resourcesEmptyTransactionGreySvg,
              width: 80,
              height: 80,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              context.l10n.noResult,
              style: TextStyle(
                color: context.colorScheme.thirdText,
                fontSize: 14,
              ),
            ),
          ),
          const Spacer(flex: 164),
        ],
      );
}
