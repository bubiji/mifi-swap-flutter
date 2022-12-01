import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/r.dart';
import '../models/m_swap_assetmeta_CartModel.dart';

class AddSwapAssetWidget extends StatelessWidget {
  // var sortName;

  const AddSwapAssetWidget({
    Key? key,
    required this.data,
    // required this.sortName,
  }) : super(key: key);

  final SwapAsset data;
  //final SwapAssetSortName sortName;

  @override
  Widget build(BuildContext context) {
    void onTap() {
      //context.push(swapAssetDetailPath.toUri({'id': data.swapAsset.id}));

      // TODO(DeanLee): TODO 添加资产到本地钱包列表 用于体现充值.
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // SymbolIconWithBorder(
            //   symbolUrl: data.,
            //   chainUrl: data.swapAsset.chainLogo,
            //   size: 40,
            //   chainSize: 14,
            //   chainBorder: BorderSide(
            //     color: context.colorScheme.background,
            //     width: 1.5,
            //   ),
            // ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Row(
                  //   children: [
                  //     Text(
                  //       ' ${data.swapAsset.symbol}'.overflow,
                  //       style: TextStyle(
                  //         color: context.colorScheme.primaryText,
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.w400,
                  //       ),
                  //     ),
                  //   ],
                  // ),
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
            _AddButton(
              item: data,
            ), //sortName: sortName,
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.item});
  final SwapAsset item;

  @override
  Widget build(BuildContext context) {
    final isInCart = context.select<MySwapAsset_CartModel, bool>(
      (cart) => cart.items.contains(item),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
            icon: SvgPicture.asset(R.resourcesPlusSvg,
                height: 16, width: 16, color: context.colorScheme.primaryText),
            onPressed: () {
              print('Pressed');

              // if(!variantsList.contains('B'))
              // {//not found add data to list
              //   variantsList.add('B');
              // }
              //variantsList = variantsList.toSet().toList();
            })
      ],
    );
  }
}
