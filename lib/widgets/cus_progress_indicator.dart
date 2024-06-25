import 'package:flutter/cupertino.dart';

class CusProgressIndicator {
  static BuildContext? _context;

  static void show(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        _context = context;
        return const PopScope(
          canPop: false,
          child: CupertinoActivityIndicator(radius: 20),
        );
      },
    ).then((_) {
      _context = null;
    });
  }

  static void close() {
    if (_context == null) {
      throw "Please call before 'CusProgressIndicator.show()'";
    }
    Navigator.pop(_context!);
  }

  static bool canClose() => _context != null;

  CusProgressIndicator._();
}
