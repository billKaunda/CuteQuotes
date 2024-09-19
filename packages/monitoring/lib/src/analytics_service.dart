import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

//Wrapper around [FirebaseAnalytics]
class AnalyticsService {
  AnalyticsService({
    @visibleForTesting FirebaseAnalytics? analytics,
  }) : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  //This method takes the screen name for a parameter and logs it into
  // the Firebase Analytics service
  Future<void> logCurrentScreen(String screenName) {
    return _analytics.logScreenView(
      screenName: screenName,
    );
  }

  //This method takes a custom event and logs it into the Firebase 
  // Analytics Service
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) {
    return _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }
}
