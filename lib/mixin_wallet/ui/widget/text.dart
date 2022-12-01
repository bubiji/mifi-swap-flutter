import 'package:flutter/material.dart';

/// flutter has wrong text layout on Android WebView.
/// https://github.com/flutter/flutter/issues/86776
class MixinText extends StatelessWidget {
  const MixinText(
    this.data, {
    Key? key,
    this.style,
    this.selectable = false,
    this.textAlign,
    this.overflow,
    this.maxLines,
  }) : super(key: key);

  final String data;
  final TextStyle? style;
  final bool selectable;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => Text(
        data,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
      );
}
