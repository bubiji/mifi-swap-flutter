import 'package:flutter/material.dart';

class NotFound extends StatelessWidget {
  const NotFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('404')),
        body: const Center(
          child: Text('404'),
        ),
      );
}
