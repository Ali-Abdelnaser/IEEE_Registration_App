import 'package:flutter/material.dart';

class AppNavigator {
  static void slideLikePageView(BuildContext context, Widget screen, {bool replace = true}) {
    _navigate(
      context,
      screen,
      replace,
      (animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      const Duration(milliseconds: 350),
    );
  }

  static void fade(BuildContext context, Widget screen, {bool replace = true}) {
    _navigate(
      context,
      screen,
      replace,
      (animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  static void scale(BuildContext context, Widget screen, {bool replace = true}) {
    _navigate(
      context,
      screen,
      replace,
      (animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: child,
        );
      },
    );
  }

  static void _navigate(
    BuildContext context,
    Widget screen,
    bool replace,
    Widget Function(Animation<double>, Animation<double>, Widget) transition, [
    Duration duration = const Duration(milliseconds: 300),
  ]) {
    final route = PageRouteBuilder(
      transitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return transition(animation, secondaryAnimation, child);
      },
    );

    if (replace) {
      Navigator.pushReplacement(context, route);
    } else {
      Navigator.push(context, route);
    }
  }
}
