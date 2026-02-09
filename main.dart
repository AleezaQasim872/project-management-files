import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'services/notification_service.dart';

// AUTH SCREENS
import 'screens/auth/login_selection_screen.dart';
import 'screens/auth/admin_login_screen.dart';
import 'screens/auth/participant_login_screen.dart';
import 'screens/auth/signup_screen.dart';

// DASHBOARDS
import 'screens/admin/admin_dashboard.dart';
import 'screens/hod/hod_dashboard.dart';

// PROJECT SCREENS
import 'screens/project/add_members_screen.dart';
import 'screens/project/project_task_screen.dart';
import 'screens/project/my_project_progress_screen.dart';
import 'screens/project/overall_project_progress_screen.dart';

// OTHERS
import 'screens/role_selection_screen.dart';
import 'screens/placeholder_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 🌍 Timezone
    tz.initializeTimeZones();

    // 🔥 Firebase
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyD0MWT0lld6_0zxpNsZtmcaFRK_J5DMmHk",
          authDomain: "university-store-app.firebaseapp.com",
          projectId: "university-store-app",
          storageBucket: "university-store-app.appspot.com",
          messagingSenderId: "305054979246",
          appId: "1:305054979246:web:0ccd0d97d77b285463893f",
          measurementId: "G-HXG75Q8DKJ",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }

    // 🔔 Notifications
    final notificationService = NotificationService();
    await notificationService.init();

    // 🧠 Hive
    await Hive.initFlutter();
    await Hive.openBox('items');
    await Hive.openBox('requests');
    await Hive.openBox('issued');
    await Hive.openBox('reports');

    // ✅ Run App
    runApp(const MyApp());
  } catch (e, s) {
    debugPrint("Initialization error: $e");
    debugPrint("$s");
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            "App failed to initialize:\n$e",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'University Store Management',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginSelectionScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/participant-login': (context) => const ParticipantLoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/select-role': (context) => const RoleSelectionScreen(),
        '/admin': (context) => const AdminDashboard(),
        '/admin-items': (context) =>
            const PlaceholderScreen(title: 'Manage Items'),
        '/admin-requests': (context) =>
            const PlaceholderScreen(title: 'All Requests'),
        '/admin-issued': (context) =>
            const PlaceholderScreen(title: 'Issued Items'),
        '/admin-reports': (context) =>
            const PlaceholderScreen(title: 'Reports'),
        '/hod': (context) => const HodDashboard(),
        '/add-members': (context) => AddMembersScreen(),
        '/project-task': (context) => const ProjectTaskScreen(),
        '/my-project-progress': (context) => MyProjectProgressScreen(),
        '/overall-project-progress': (context) => OverallProjectProgressScreen(),
        '/request-item': (context) =>
            const PlaceholderScreen(title: 'Request Item'),
        '/my-requests': (context) =>
            const PlaceholderScreen(title: 'My Requests'),
      },
    );
  }
}
