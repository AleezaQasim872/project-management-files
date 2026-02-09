import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'request_items_screen.dart';

class HodDashboard extends StatelessWidget {
  const HodDashboard({super.key});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/');
  }

  Widget actionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: iconColor.withOpacity(0.15),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "HOD / Staff Panel",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Manage your requests efficiently",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            /// 🔹 Request Item
            actionCard(
              context: context,
              title: "Request Item",
              subtitle: "Send new inventory request",
              icon: Icons.add_box_outlined,
              iconColor: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RequestItemsScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            /// 🔹 My Requests
            actionCard(
              context: context,
              title: "My Requests",
              subtitle: "View request status & history",
              icon: Icons.list_alt_outlined,
              iconColor: Colors.deepPurple,
              onTap: () {
                Navigator.pushNamed(context, '/my-requests');
              },
            ),
          ],
        ),
      ),
    );
  }
}