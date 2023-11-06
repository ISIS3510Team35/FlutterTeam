import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class Crashlyc extends StatefulWidget {
  const Crashlyc({super.key});
  @override
  _CrashlycState createState() => _CrashlycState();
}

class _CrashlycState extends State<Crashlyc> {
  int crashCount = 0;

  @override
  void initState() {
    super.initState();
    fetchCrashCount().then((value) {
      setState(() {
        crashCount = value;
      });
    });
  }

  Future<int> fetchCrashCount() async {
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      // Simulated list of issues for demonstration purposes
      final List<String> issues = ["issue1", "issue2", "issue3"];
      final DateTime now = DateTime.now();
      final DateTime weekAgo = now.subtract(const Duration(days: 7));
      final List<String> weekIssues = issues
          .where((issue) =>
              DateTime.parse(issue).isAfter(weekAgo) &&
              DateTime.parse(issue).isBefore(now))
          .toList();
      return weekIssues.length;
    } on Exception catch (e) {
      //print('Firebase Exception: $e');
      e;
      return 0;
    } catch (e) {
      //print('Error: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Crash Count'),
      ),
      body: Center(
        child: Text(
          'Crash Count: $crashCount',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
