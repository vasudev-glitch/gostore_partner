import 'dart:io';
import 'package:flutter/cupertino.dart';

class PlatformPageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  PlatformPageRoute({required this.builder})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (Platform.isIOS) {
        return CupertinoPageTransition(
          primaryRouteAnimation: animation,
          secondaryRouteAnimation: secondaryAnimation,
          child: child,
          linearTransition: true,
        );
      } else {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      }
    },
  );
}
