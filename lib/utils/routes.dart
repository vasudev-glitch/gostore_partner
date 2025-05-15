import 'package:flutter/material.dart';

class AppRoutes {
  // 🔑 Route names
  static const splash = '/splash';
  static const login = '/login';
  static const profile = '/profile';
  static const dashboard = '/dashboard';
  static const panel = '/panel';
  static const analytics = '/analytics';
  static const inventory = '/inventory';
  static const fraud = '/fraud';
  static const controls = '/controls';

  /// 🚀 Push: Go to a route
  static Future<void> go(BuildContext context, String route, {Object? args}) {
    return Navigator.pushNamed(context, route, arguments: args);
  }

  /// 🚀 Replace: Replace current route
  static Future<void> replace(BuildContext context, String route, {Object? args}) {
    return Navigator.pushReplacementNamed(context, route, arguments: args);
  }

  /// 🚀 Clear stack and push
  static Future<void> clearStackAndGo(BuildContext context, String route, {Object? args}) {
    return Navigator.pushNamedAndRemoveUntil(context, route, (route) => false, arguments: args);
  }
}
