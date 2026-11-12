import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../utils/route_util.dart';

/// Go back / forward with the mouse side buttons on every page.
///
/// It listens to raw pointer events, so wrap the whole app (all routes) with it.
class EHMouseNavigationListener extends StatelessWidget {
  final Widget child;

  const EHMouseNavigationListener({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      child: child,
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    if (event.kind != PointerDeviceKind.mouse) {
      return;
    }

    if (event.buttons == kBackMouseButton) {
      backActiveRoute();
    } else if (event.buttons == kForwardMouseButton) {
      forwardRoute();
    }
  }
}
