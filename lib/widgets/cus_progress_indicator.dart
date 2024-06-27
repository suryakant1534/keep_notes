import 'dart:async';

import 'package:flutter/cupertino.dart';

typedef LoadMethod = Future<void> Function();

class CusProgressIndicator {
  final StreamController<BuildContext> _controller = StreamController();

  Future<void> showIndicator(BuildContext context) async {
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        _controller.add(context);
        return const PopScope(
          canPop: false,
          child: CupertinoActivityIndicator(radius: 20),
        );
      },
    );
  }

  CusProgressIndicator._(LoadMethod futureMethod) {
    _controller.stream.listen((BuildContext context) async {
        await futureMethod();
        if (context.mounted) Navigator.pop(context);
        await _controller.close();
    });
  }

  static Future<void> show(BuildContext context,
      {required LoadMethod futureMethod}) async {
    final obj = CusProgressIndicator._(futureMethod);
    await obj.showIndicator(context);
  }
}
