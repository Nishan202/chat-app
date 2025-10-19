import 'package:flutter/material.dart';

class MyRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    debugPrint('➡️ Pushed route: ${route.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    debugPrint('⬅️ Popped route: ${route.settings.name}');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    debugPrint('🗑️ Removed route: ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    debugPrint(
      '🔁 Replaced route: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}',
    );
  }
}
