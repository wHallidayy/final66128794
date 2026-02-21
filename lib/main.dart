import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'helpers/database_helper.dart';
import 'helpers/firestore_helper.dart';
import 'helpers/sync_helper.dart';
import 'screens/home_screen.dart';
import 'screens/all_events_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/select_station_screen.dart';
import 'screens/select_violation_screen.dart';
import 'screens/report_form_screen.dart';
import 'screens/report_success_screen.dart';
import 'screens/report_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('.env not found, using fallback config');
  }

  // SQLite (local)
  DatabaseHelper.initFfi();
  await DatabaseHelper().database;

  // Firebase (cloud)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirestoreHelper().seedIfEmpty();
    await SyncHelper().syncAll();
  } catch (e) {
    debugPrint('Firebase init error (continuing offline): $e');
  }

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'รายงานทุจริตเลือกตั้ง',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/home': (context) => HomeScreen(),
        '/all_events': (context) => AllEventsScreen(),
        '/stats': (context) => StatsScreen(),
        '/select_station': (context) => SelectStationScreen(),
        '/select_violation': (context) => SelectViolationScreen(),
        '/report_form': (context) => ReportFormScreen(),
        '/report_success': (context) => ReportSuccessScreen(),
        '/report_detail': (context) => ReportDetailScreen(),
      },
    );
  }
}
