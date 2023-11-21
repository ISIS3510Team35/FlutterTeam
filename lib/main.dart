import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fud/services/resources/firebase_options.dart';
import 'package:fud/services/ui/login/login.dart';
import 'package:fud/appRouter.dart';

import 'package:fud/services/others/firebase_services.dart';
import 'package:fud/services/resources/localStorage.dart';

void main() async {
  DateTime appStartTime = DateTime.now();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var localStorage = LocalStorage();
  await localStorage.init();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

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
