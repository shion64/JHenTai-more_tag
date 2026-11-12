import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jhentai/src/extension/list_extension.dart';
import 'package:jhentai/src/pages/home_page.dart';
import 'package:jhentai/src/routes/eh_page.dart';
import 'package:jhentai/src/routes/routes.dart';
import 'package:jhentai/src/setting/style_setting.dart';

import '../model/jh_layout.dart';
import '../pages/layout/desktop/desktop_layout_page_logic.dart';

/// A route closed by back action. It can be reopened by [forwardRoute] (mouse forward button).
class _ClosedRoute {
  final String routeName;
  final dynamic arguments;

  const _ClosedRoute(this.routeName, this.arguments);
}

const int _maxForwardRoutes = 20;

/// Routes which should never be reopened by forward action.
const Set<String> _noForwardRoutes = {Routes.home, Routes.lock, Routes.blank, Routes.desktopHome};

/// Routes on which mouse side buttons must not navigate:
/// the read page and keyboard shortcuts page use them by themselves, and the lock page must not be dismissed.
const Set<String> _mouseNavigationDisabledRoutes = {Routes.read, Routes.settingKeyboardShortcuts, Routes.lock};

final List<_ClosedRoute> _forwardRoutes = [];
bool _isGoingForward = false;

/// adaptive to different layout
Future<T?>? toRoute<T>(
  String routeName, {
  dynamic arguments,
  bool preventDuplicates = true,
  bool? offAllBefore,
  Map<String, String>? parameters,
  int? id,
}) {
  if (!_isGoingForward) {
    clearForwardRoutes();
  }

  EHPage page = Routes.pages.firstWhere((page) => page.name == routeName);

  /// only one [Route]
  if (styleSetting.isInMobileLayout || page.side == Side.fullScreen || id == fullScreen) {
    return Get.toNamed(
      routeName,
      arguments: arguments,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
    );
  }

  if (page.side == Side.left) {
    if (styleSetting.layout.value == LayoutMode.desktop) {
      DesktopLayoutPageLogic logic = Get.find<DesktopLayoutPageLogic>();

      int? tabIndex = logic.state.icons.firstIndexWhereOrNull((icon) => icon.routeName == routeName);
      if (tabIndex != null) {
        logic.handleTapTabBarButton(tabIndex);
        return Future.value(null);
      } else {
        return Get.toNamed(
          routeName,
          arguments: arguments,
          id: left,
          parameters: parameters,
          preventDuplicates: preventDuplicates,
        );
      }
    }

    /// left [Route]
    return Get.toNamed(
      routeName,
      arguments: arguments,
      id: styleSetting.isInV2Layout ? leftV2 : left,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
    );
  }

  if (offAllBefore ?? page.offAllBefore) {
    Get.until(
      (route) => route.settings.name == Routes.blank,
      id: styleSetting.isInV2Layout ? rightV2 : right,
    );

    Get.engine.addPostFrameCallback((_) {
      Get.toNamed(
        routeName,
        arguments: arguments,
        id: styleSetting.isInV2Layout ? rightV2 : right,
        parameters: parameters,
        preventDuplicates: preventDuplicates,
      );
    });

    return null;
  }

  /// right [Route]
  if (preventDuplicates && isRouteAtTop(routeName)) {
    return null;
  }

  return Get.toNamed(
    routeName,
    arguments: arguments,
    id: styleSetting.isInV2Layout ? rightV2 : right,
    parameters: parameters,
    preventDuplicates: preventDuplicates,
  );
}

/// pop current route
void backRoute<T>({
  String? currentRoute,
  T? result,
  bool closeOverlays = false,
  bool canPop = true,
}) {
  Side side = Routes.pages.firstWhereOrNull((page) => page.name == currentRoute)?.side ?? Side.fullScreen;

  int? id = styleSetting.isInMobileLayout
      ? null
      : side == Side.left
          ? styleSetting.isInV2Layout
              ? leftV2
              : left
          : side == Side.right
              ? styleSetting.isInV2Layout
                  ? rightV2
                  : right
              : null;

  return _popAndRecord(id, () => Get.back(result: result, closeOverlays: closeOverlays, canPop: canPop, id: id));
}

/// pop current active route triggered by esc or fifth button or system back button
void popLeftRoute<T>({
  T? result,
  bool closeOverlays = false,
  bool canPop = true,
}) {
  int? id = styleSetting.isInMobileLayout
      ? null
      : styleSetting.isInV2Layout
          ? leftV2
          : left;

  return _popAndRecord(id, () => Get.back(result: result, closeOverlays: closeOverlays, canPop: canPop, id: id));
}

/// pop current active right route triggered by esc or fifth button or system back button
void popRightRoute<T>({
  T? result,
  bool closeOverlays = false,
  bool canPop = true,
}) {
  int? id = styleSetting.isInMobileLayout
      ? null
      : styleSetting.isInV2Layout
          ? rightV2
          : right;

  return _popAndRecord(id, () => Get.back(result: result, closeOverlays: closeOverlays, canPop: canPop, id: id));
}

/// pop current route and push a new route
Future<T?>? offRoute<T>(
  String routeName, {
  dynamic arguments,
  bool preventDuplicates = true,
  Map<String, String>? parameters,
}) {
  clearForwardRoutes();

  Side side = Routes.pages.firstWhereOrNull((page) => page.name == routeName)?.side ?? Side.fullScreen;

  return Get.offNamed(
    routeName,
    arguments: arguments,
    id: styleSetting.isInMobileLayout
        ? null
        : side == Side.left
            ? styleSetting.isInV2Layout
                ? leftV2
                : left
            : side == Side.right
                ? styleSetting.isInV2Layout
                    ? rightV2
                    : right
                : null,
    preventDuplicates: preventDuplicates,
    parameters: parameters,
  );
}

/// pop routes until [predicate] match
void untilRoute({String? currentRoute, required RoutePredicate predicate}) {
  Side side = Routes.pages.firstWhereOrNull((page) => page.name == currentRoute)?.side ?? Side.fullScreen;

  return Get.until(
    predicate,
    id: styleSetting.isInMobileLayout
        ? null
        : side == Side.left
            ? styleSetting.isInV2Layout
                ? leftV2
                : left
            : side == Side.right
                ? styleSetting.isInV2Layout
                    ? rightV2
                    : right
                : null,
  );
}

/// pop all pages in right screen if exists
void untilRoute2BlankPage() {
  if (Get.keys.containsKey(right) && Get.keys[right]?.currentContext != null) {
    Get.until((route) => route.settings.name == Routes.blank, id: right);
  }

  if (Get.keys.containsKey(rightV2) && Get.keys[rightV2]?.currentContext != null) {
    Get.until((route) => route.settings.name == Routes.blank, id: rightV2);
  }
}

/// pop all pages in right screen if exists
void untilRoute2DesktopHomePage() {
  Get.until((route) => route.settings.name == Routes.desktopHome, id: left);
}

/// check if route with [routeName] is at top
bool isRouteAtTop(String routeName) {
  Side side = Routes.pages.firstWhereOrNull((page) => page.name == routeName)?.side ?? Side.fullScreen;

  if (styleSetting.isInMobileLayout || side == Side.fullScreen) {
    return Get.currentRoute == routeName;
  }

  if (side == Side.left) {
    if (styleSetting.actualLayout == LayoutMode.desktop) {
      DesktopLayoutPageLogic logic = Get.find<DesktopLayoutPageLogic>();
      return logic.state.icons[logic.state.selectedTabIndex].routeName == routeName || leftRouting.current == routeName;
    }
    return leftRouting.current == routeName;
  }

  return rightRouting.current == routeName;
}

/// forget the routes that can be reopened by forward action, called when user navigates to somewhere new
void clearForwardRoutes() {
  _forwardRoutes.clear();
}

/// pop current active route, triggered by mouse back button
void backActiveRoute() {
  if (_isMouseNavigationBlocked()) {
    return;
  }

  /// a page is opened over home page: mobile layout, read page, etc.
  if (Get.key.currentState?.canPop() == true) {
    _popAndRecord(null, () => Get.back());
    return;
  }

  if (styleSetting.isInMobileLayout) {
    return;
  }

  int rightId = styleSetting.isInV2Layout ? rightV2 : right;
  int leftId = styleSetting.isInV2Layout ? leftV2 : left;

  if (Get.keys[rightId]?.currentState?.canPop() == true) {
    popRightRoute();
    return;
  }

  if (Get.keys[leftId]?.currentState?.canPop() == true) {
    popLeftRoute();
  }
}

/// reopen the route most recently closed by back action, triggered by mouse forward button
void forwardRoute() {
  if (_forwardRoutes.isEmpty || _isMouseNavigationBlocked()) {
    return;
  }

  _ClosedRoute closedRoute = _forwardRoutes.removeLast();

  _isGoingForward = true;
  try {
    toRoute(
      closedRoute.routeName,
      arguments: closedRoute.arguments,
      preventDuplicates: false,
      offAllBefore: false,
    );
  } finally {
    _isGoingForward = false;
  }
}

/// whether mouse back/forward buttons should be ignored now
bool _isMouseNavigationBlocked() {
  /// dialog or bottom sheet is shown
  if (_topRoute(null) is PopupRoute) {
    return true;
  }

  return [null, left, right, leftV2, rightV2].any((int? id) => _mouseNavigationDisabledRoutes.contains(_topRoute(id)?.settings.name));
}

/// the [Route] on top of navigator [id], null means the root navigator
Route<dynamic>? _topRoute(int? id) {
  NavigatorState? navigator = id == null ? Get.key.currentState : Get.keys[id]?.currentState;

  Route<dynamic>? top;
  navigator?.popUntil((route) {
    top = route;
    return true;
  });
  return top;
}

/// run [pop] and remember the route it closed, so that it can be reopened by [forwardRoute]
void _popAndRecord(int? id, VoidCallback pop) {
  Route<dynamic>? top = _topRoute(id);

  pop();

  /// [Get.back] may close a dialog or snackbar instead, so check whether [top] was really popped
  if (top != null && !top.isActive) {
    _recordClosedRoute(top);
  }
}

void _recordClosedRoute(Route<dynamic> route) {
  String? routeName = route.settings.name;

  if (route is! PageRoute || routeName == null || _noForwardRoutes.contains(routeName)) {
    return;
  }

  /// routes with path params can't be matched by [toRoute]
  if (!Routes.pages.any((page) => page.name == routeName)) {
    return;
  }

  _forwardRoutes.add(_ClosedRoute(routeName, route.settings.arguments));
  if (_forwardRoutes.length > _maxForwardRoutes) {
    _forwardRoutes.removeAt(0);
  }
}
