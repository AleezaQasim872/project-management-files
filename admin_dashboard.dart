import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/');
  }

  Widget dashboardTile(
    BuildContext context,
    String title,
    IconData icon,
    String route,
    List<Color> gradientColors,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 38, color: Colors.white),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            const Text(
              "Welcome, Admin 👋",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Manage inventory, requests and reports",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Dashboard Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  dashboardTile(
                    context,
                    "Manage Items",
                    Icons.inventory_2,
                    '/admin-items',
                    [Colors.indigo, Colors.indigoAccent],
                  ),
                  dashboardTile(
                    context,
                    "All Requests",
                    Icons.list_alt,
                    '/admin-requests',
                    [Colors.blue, Colors.lightBlueAccent],
                  ),
                  dashboardTile(
                    context,
                    "Issued Items",
                    Icons.assignment_turned_in,
                    '/admin-issued',
                    [Colors.teal, Colors.greenAccent],
                  ),
                  dashboardTile(
                    context,
                    "Reports",
                    Icons.bar_chart,
                    '/admin-reports',
                    [Colors.deepPurple, Colors.purpleAccent],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}