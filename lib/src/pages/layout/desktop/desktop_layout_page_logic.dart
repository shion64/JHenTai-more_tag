import 'package:flutter/cupertino.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:get/get.dart';
import 'package:jhentai/src/routes/routes.dart';
import 'package:jhentai/src/service/windows_service.dart';
import 'package:jhentai/src/utils/route_util.dart';

import '../../../mixin/double_tap_to_refresh_logic_mixin.dart';
import '../../home_page.dart';
import 'desktop_layout_page_state.dart';

class DesktopLayoutPageLogic extends GetxController with DoubleTapToRefreshLogicMixin {
  final String tabBarId = 'tabBarId';
  final String leftColumnId = 'leftColumnId';

  @override
  DesktopLayoutPageState state = DesktopLayoutPageState();

  final ResizableController resizableController = ResizableController();

  @override
  void onInit() {
    super.onInit();

    resizableController.addListener(() {
      windowService.handleDoubleColumnResized(resizableController.ratios);
    });
  }

  @override
  void onClose() {
    super.onClose();

    resizableController.dispose();
  }

  void updateHoveringTabIndex(int? index) {
    state.hoveringTabIndex = index;
    update([tabBarId]);
  }

  /// tabs selected before / after the current one, used by mouse back / forward buttons
  final List<int> _backTabs = [];
  final List<int> _forwardTabs = [];
  static const int _maxTabHistory = 20;

  /// tap another bar -> change index
  /// at gallery bar and tap gallery bar again -> scroll to top
  /// at gallery bar and tap gallery bar twice -> scroll to top and refresh
  void handleTapTabBarButton(int index) {
    clearForwardRoutes();

    if (index != state.selectedTabIndex) {
      _backTabs.add(state.selectedTabIndex);
      if (_backTabs.length > _maxTabHistory) {
        _backTabs.removeAt(0);
      }
    }

    _selectTab(index);
  }

  /// go back to the previously selected tab, return false if there is none
  bool backTab() {
    if (_backTabs.isEmpty) {
      return false;
    }

    _forwardTabs.add(state.selectedTabIndex);
    _selectTab(_backTabs.removeLast());
    return true;
  }

  /// go forward to the tab selected before [backTab], return false if there is none
  bool forwardTab() {
    if (_forwardTabs.isEmpty) {
      return false;
    }

    _backTabs.add(state.selectedTabIndex);
    _selectTab(_forwardTabs.removeLast());
    return true;
  }

  void clearForwardTabs() {
    _forwardTabs.clear();
  }

  void _selectTab(int index) {
    state.icons[index].shouldRender = true;

    int prevIndex = state.selectedTabIndex;
    state.selectedTabIndex = index;

    if (!isRouteAtTop(Routes.desktopHome)) {
      untilRoute2DesktopHomePage();
    }

    if (prevIndex != index) {
      leftRouting.args = null;
      Get.parameters = {};
      update([tabBarId, leftColumnId]);
      return;
    }

    ScrollController? scrollController = state.icons[index].scrollController?.call();
    handleTap2Scroll2Top(scrollController);
  }
}
