import 'dart:async';
import 'package:flutter/services.dart';

/// Screenshot privacy is enabled only while a private route is mounted.
/// Ref counting preserves protection during Vault -> chat transitions.
class PrivateScreenGuard {
  static const _channel = MethodChannel('studyverse/privacy');
  static int _privateRoutes = 0;

  static void enter() {
    _privateRoutes++;
    if (_privateRoutes == 1) {
      unawaited(_send(true));
    }
  }

  static void leave() {
    if (_privateRoutes == 0) return;
    _privateRoutes--;
    if (_privateRoutes == 0) {
      unawaited(_send(false));
    }
  }

  static Future<void> _send(bool enabled) async {
    try {
      await _channel.invokeMethod<void>('setPrivateScreen',
          <String, bool>{'enabled': enabled});
    } on MissingPluginException {
      // Widget tests / non-Android hosts do not provide native privacy APIs.
    } on PlatformException {
      // Android is still transitioning; never crash the private UI.
    }
  }
}
