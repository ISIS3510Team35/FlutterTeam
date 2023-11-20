import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fud/services/resources/firebase_options.dart';
import 'package:fud/services/ui/login.dart';
import 'package:fud/appRouter.dart';

import 'package:fud/services/resources/firebase_services.dart';
import 'package:fud/services/localStorage.dart';

void main() async {
  DateTime appStartTime = DateTime.now();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var localStorage = LocalStorage();
  localStorage.init();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runZonedGuarded<Future<void>>(() async {
    runApp(const MyApp());
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });

  DateTime appEndTime = DateTime.now();
  Duration appStartupTime = appEndTime.difference(appStartTime);
  addStartTime(appStartTime, appStartupTime);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fUd',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 114, 100, 94)),
        useMaterial3: true,
      ),
      initialRoute: LoginPage.routeName,
      routes: AppRouter.routes,
    );
  }
}
