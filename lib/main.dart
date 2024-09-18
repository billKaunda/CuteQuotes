import 'dart:async';
import 'dart:isolate';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:routemaster/routemaster.dart';
import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:fav_qs_api/fav_qs_api.dart';
import 'package:forgot_my_password/forgot_my_password.dart';
import 'package:profile_menu/profile_menu.dart';
import 'package:quote_list/quote_list.dart';
import 'package:sign_in/sign_in.dart';
import 'package:sign_up/sign_up.dart';
import 'package:update_profile/update_profile.dart';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:monitoring/monitoring.dart';
import 'package:quote_repository/quote_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:cutequotes/routing_table.dart';
import 'package:cutequotes/l10n/app_localizations.dart';
import 'package:cutequotes/screen_view_observer.dart';

void main() async {
  //Mark the ErrorReportingService as late and instantiate it so
  //that it doesn't instantiate before initializeMonitoringPackage()
  // call.
  late final errorReportingService = ErrorReportingService();

  //runZonedGuarded() method catches errors which are thrown when
  // running an asynchronous code.
  runZonedGuarded<Future<void>>(
    () async {
      //Ensure that Flutter is initialized. When initializing an app, the
      // app interacts with its native layers through async operation. This
      // happens via platform channels.
      WidgetsFlutterBinding.ensureInitialized();

      //Initialize Firebase core services, which are defined in the
      // monitoring.dart file.
      await initializeMonitoringPackage();

      //Crash the app to test it with Firebase's Crashlytics
      //final explicitCrash = ExplicitCrash();
      //explicitCrash.crashTheApp();

      //Initialize RemoteValueService and load feature flags from remote
      // config.
      final remoteValueService = RemoteValueService();
      await remoteValueService.load();

      //This lambda expression invokes the recordFlutterError method
      // with the FlutterErrorDetails passed in its argument which
      //holds the stacktrace, exception details, e.t.c.
      FlutterError.onError = errorReportingService.recordFlutterError;

      //This isolate function handles errors outside of Flutter context.
      // Add a listener to the current isolate for additional error
      // handling.
      Isolate.current.addErrorListener(
        RawReceivePort((pair) async {
          //Extract error and stacktrace from the error listener
          final List<dynamic> errorAndStackTrace = pair;
          await errorReportingService.recordError(
            errorAndStackTrace.first,
            errorAndStackTrace.last,
          );
        }).sendPort,
      );

      HttpOverrides.global = WonderHttpOverrides();

      //Run the app with the initialized services.
      runApp(WonderWords(
        remoteValueService: remoteValueService,
      ));
    },
    //Handle errors caught in the zone-errors that happen asynchronously.
    (error, stack) => errorReportingService.recordError(
      error,
      stack,
      fatal: true,
    ),
  );
}

class WonderHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class WonderWords extends StatefulWidget {
  const WonderWords({
    required this.remoteValueService,
    super.key,
  });
  final RemoteValueService remoteValueService;

  @override
  State<WonderWords> createState() => _WonderWordsState();
}

class _WonderWordsState extends State<WonderWords> {
  final _keyValueStorage = KeyValueStorage();
  final _analyticsService = AnalyticsService();
  //final _dynamicLinkService = DynamicLinkService();

  late final UserRepository _userRepository;
  late final FavQsApi _favQsApi;
  late final QuoteRepository _quoteRepository;
  late final RoutemasterDelegate _routerDelegate;

  final _lightTheme = LightCuteThemeData();
  final _darkTheme = DarkCuteThemeData();
  late StreamSubscription _incomingDynamicLinkSubscription;

  @override
  void initState() {
    super.initState();

    _favQsApi = FavQsApi(
      userTokenSupplier: () => _userRepository.getToken(),
    );

    _userRepository = UserRepository(
      noSqlStorage: _keyValueStorage,
      remoteApi: _favQsApi,
    );

    _quoteRepository = QuoteRepository(
      remoteApi: _favQsApi,
      keyValueStorage: _keyValueStorage,
    );

    _routerDelegate = RoutemasterDelegate(
      //Add observers to RoutemasterDelegate in order to track
      // navigation from one screen to another
      observers: [
        ScreenViewObserver(
          analyticsService: _analyticsService,
        ),
      ],
      routesBuilder: (context) => RouteMap(
        routes: buildRoutingTable(
          routerDelegate: _routerDelegate,
          userRepository: _userRepository,
          quoteRepository: _quoteRepository,
          remoteValueService: widget.remoteValueService,
        ),
      ),
    );
    
    /*
    //_openInitialDynamicLinkIfAny();
    
    ///Dynamic links is no longer supported
    _incomingDynamicLinkSubscription =
        _dynamicLinkService.onNewDynamicLinkPath().listen(
              _routerDelegate.push,
            );
    */
  }

  /*
  Future<void> _openInitialDynamicLinkIfAny() async {
    final path = await _dynamicLinkService.getInitialDynamicLinkPath();
    if (path != null) {
      _routerDelegate.push(path);
    }
  }
  */

  @override
  void dispose() {
    _incomingDynamicLinkSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DarkModePreference>(
        stream: _userRepository.getDarkModePreference(),
        builder: (context, snapshot) {
          final darkModePreference = snapshot.data;

          return CuteTheme(
            lightTheme: _lightTheme,
            darkTheme: _darkTheme,
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerDelegate: _routerDelegate,
              routeInformationParser: const RoutemasterParser(),
              theme: _lightTheme.materialThemeData,
              darkTheme: _darkTheme.materialThemeData,
              themeMode: darkModePreference?.toThemeMode(),
              supportedLocales: const [
                Locale('en', ''),
                Locale('pt', 'BR'),
                Locale('sw', 'KE'),
                Locale('sw', 'UG'),
                Locale('sw', 'TZ'),
              ],
              localizationsDelegates: const [
                //The delegate property holds an object that knows how
                // to create and recreate instances of a given localization,
                // e.g, ComponentLibraryLocalizations based on the device's
                // language.
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                AppLocalizations.delegate,
                ComponentLibraryLocalizations.delegate,
                ForgotMyPasswordLocalizations.delegate,
                ProfileMenuLocalizations.delegate,
                QuoteListLocalizations.delegate,
                SignInLocalizations.delegate,
                SignUpLocalizations.delegate,
                UpdateProfileLocalizations.delegate,
              ],
            ),
          );
        });
  }
}

extension on DarkModePreference {
  ThemeMode toThemeMode() {
    switch (this) {
      case DarkModePreference.useSystemSettings:
        return ThemeMode.system;
      case DarkModePreference.alwaysLight:
        return ThemeMode.light;
      case DarkModePreference.alwaysDark:
        return ThemeMode.dark;
    }
  }
}
