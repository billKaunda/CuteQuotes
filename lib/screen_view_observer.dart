import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:monitoring/monitoring.dart';

/*
RoutemasterObserver class monitors all the screen in and out events, 
i.e, when a new screen enters and another exits.
*/
class ScreenViewObserver extends RoutemasterObserver {
  ScreenViewObserver({
    required this.analyticsService,
  });

  final AnalyticsService analyticsService;

  void _sendScreenView(PageRoute<dynamic> route) {
    //Extract the name of the screen from the route settings
    final String? screenName = route.settings.name;

    //Record the screen view event (once verified that the screen name
    // is non-null) by calling the setCurrentScreen predefined method.
    if (screenName != null) {
      analyticsService.logCurrentScreen(screenName);
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }
}
