import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class NativeScrollBuilder extends HookWidget {
  const NativeScrollBuilder({Key? key, required this.builder})
      : super(key: key);

  final Widget Function(BuildContext context, ScrollController controller)
      builder;

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    return builder(context, controller);
  }
}
