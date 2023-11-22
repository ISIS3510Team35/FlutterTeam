import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fud/appRouter.dart';
import 'package:fud/services/resources/firebase_options.dart';
import 'package:fud/services/resources/localStorage.dart';
import 'package:fud/services/resources/repository.dart';
import 'package:fud/services/ui/login/login.dart';

void main() async {
  // Record the start time of the application
  DateTime appStartTime = DateTime.now();

  // Ensure that the Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with default options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local storage
  var localStorage = LocalStorage();
  await localStorage.init();

  // Set preferred orientation to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Set up error handling for Flutter errors and platform-specific errors
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Run the application within a zone to capture unhandled errors
  runZonedGuarded<Future<void>>(() async {
    runApp(const MyApp());
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });

  // Record the end time and calculate the startup time
  DateTime appEndTime = DateTime.now();
  Duration appStartupTime = appEndTime.difference(appStartTime);

  // Initialize and use the repository to fetch and record startup time
  final repository = Repository();
  repository.fetchTime(appStartTime, appStartupTime);
}

// MyApp class, the root of the application
class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fUd',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 114, 100, 94),
        ),
        useMaterial3: true,
      ),
      initialRoute: LoginPage.routeName,
      routes: AppRouter.routes(context),
    );
  }
}
