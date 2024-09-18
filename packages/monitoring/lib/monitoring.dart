import 'package:firebase_core/firebase_core.dart';
import 'src/firebase_options.dart';

export 'package:firebase_dynamic_links_platform_interface/src/social_meta_tag_parameters.dart';

export 'src/analytics_service.dart';

//Has been commented because dynamics_links is no longer supported
// as of 25th Aug, 2024
//export 'src/dynamic_link_service.dart'; 

export 'src/error_reporting_service.dart';
export 'src/explicit_crash.dart';
export 'src/remote_value_service.dart';

Future<void> initializeMonitoringPackage() => Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
