import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_projects_screen.dart';
import 'my_tasks_screen.dart';

class ParticipantDashboard extends StatefulWidget {
  const ParticipantDashboard({super.key});

  @override
  State<ParticipantDashboard> createState() => _ParticipantDashboardState();
}

class _ParticipantDashboardState extends State<ParticipantDashboard> {
  String userName = '';
  String userId = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'User';
      userId = prefs.getString('user_id') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $userName"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: userId.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyProjectsScreen(userId: userId),
                        ),
                      );
                    },
              child: const Text("My Projects", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: userId.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyTasksScreen(),
                        ),
                      );
                    },
              child: const Text("My Tasks", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}