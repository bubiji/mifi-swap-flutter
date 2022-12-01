import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:qr_flutter/qr_flutter.dart';

import '../../util/r.dart';

class DialogBuilder {
  DialogBuilder(
    this.context, {
    this.autoHide = true,
    this.showErrorOnce = false,
  });

  final BuildContext context;
  final bool autoHide;
  final bool showErrorOnce;
  final ValueNotifier<String> text = ValueNotifier('正在加载中......');
  final ValueNotifier<String> title = ValueNotifier('');
  final ValueNotifier<List<Widget>> children = ValueNotifier([]);
  Timer? timer;
  bool opened = false;
  bool errorShowed = false;

  void showNetworkError() {
    if (showErrorOnce && errorShowed) {
      return;
    }
    errorShowed = true;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('网络开小差, 请稍后再试'),
    ));
  }

  void showError(String err) {
    if (showErrorOnce && errorShowed) {
      return;
    }
    errorShowed = true;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(err),
    ));
  }

  void showLoadingIndicator({
    String title = '',
    String text = '',
    int timeout = 120,
  }) {
    if (text.isNotEmpty) {
      this.text.value = text;
    }
    if (title.isNotEmpty) {
      this.title.value = title;
    }

    if (opened) {
      return;
    }

    opened = true;
    timer = Timer(Duration(seconds: timeout), () {
      showNetworkError();
      hideOpenDialog();
    });
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          backgroundColor: Colors.black87,
          content: LoadingIndicator(
            title: this.title,
            text: this.text,
            children: children,
          ),
        ),
      ),
    );
  }

  void hideOpenDialog({bool force = false}) {
    if (!opened) {
      return;
    }
    timer?.cancel();
    if (autoHide || force) {
      opened = false;
      Navigator.of(context).pop();
    }
  }

  Future<T?> process<T>(
    Future<T?> Function() cb, {
    String? msg,
    String title = '',
    String text = '',
    int timeout = 120,
    bool hideError = false,
  }) async {
    showLoadingIndicator(
      title: title,
      text: text,
      timeout: timeout,
    );
    try {
      final retval = await cb();
      hideOpenDialog();
      return retval;
    } on DioError catch (e) {
      hideOpenDialog();
      if (hideError) {
        return null;
      }
      if (e is sdk.MixinApiError) {
        final err = e.error as sdk.MixinError;
        showError(err.description);
      } else {
        showNetworkError();
      }
      return null;
    } catch (e) {
      hideOpenDialog();
      if (hideError) {
        return null;
      }
      showError(msg ?? '$e');
      return null;
    }
  }

  void dispose() {
    hideOpenDialog(force: true);
  }
}

class LoadingIndicator extends HookWidget {
  const LoadingIndicator({
    required this.title,
    required this.text,
    required this.children,
    Key? key,
  }) : super(key: key);
  final ValueNotifier<String> text;
  final ValueNotifier<String> title;
  final ValueNotifier<List<Widget>> children;

  @override
  Widget build(BuildContext context) {
    final text = useValueListenable(this.text);
    final title = useValueListenable(this.title);
    final children = useValueListenable(this.children);

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          ...children,
        ],
      ),
    );
  }
}

List<Widget> getPayDialog({
  required String payUrl,
  required void Function() onOpenMixin,
  required void Function() onCancel,
}) =>
    [
      const SizedBox(height: 6),
      SizedBox(
        height: 150,
        width: 150,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: QrImage(
            data: payUrl,
            version: QrVersions.auto,
            size: 150.0,
            embeddedImage: const AssetImage(R.resourcesMixinLogoPng),
          ),
        ),
      ),
      const SizedBox(height: 6),
      ElevatedButton(
        onPressed: onOpenMixin,
        child: const Text(
          'Open Mixin',
        ),
      ),
      const SizedBox(height: 6),
      ElevatedButton(
        onPressed: onCancel,
        child: const Text(
          'Cancel',
        ),
      ),
    ];
