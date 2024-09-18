import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class ErrorReportingService {
  ErrorReportingService({
    @visibleForTesting FirebaseCrashlytics? crashlytics,
  }) : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails) {
    return _crashlytics.recordFlutterError(flutterErrorDetails);
  }

  //Records Flutter framework errors; these happen within the Flutter 
  // framework.
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    bool fatal = false,
  }) {
    return _crashlytics.recordError(
      exception,
      stack,
      fatal: fatal,
    );
  }
}
