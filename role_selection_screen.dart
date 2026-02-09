import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        title: const Text("Select Role"),
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      drawer: appDrawer(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER SECTION
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.indigo.shade50,
                      child: Image.asset(
                        "assets/images/bgnu_logo.png",
                        errorBuilder: (context, e, s) => const Icon(Icons.business, color: Colors.indigo),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Welcome Back 👋", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const Text("Role Selection", style: TextStyle(color: Colors.indigo, fontSize: 17, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              const Text("Quick Actions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),

              /// GRID VIEW - 4 COMPACT & SLIM CARDS
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12, 
                mainAxisSpacing: 12,
                childAspectRatio: 4.2, // ✅ Slim button size maintain kiya gaya hai
                children: [
                  quickActionCard(context, "Admin", Icons.admin_panel_settings, const Color(0xFF1A3B8E), "/admin", "Store Mgmt"),
                  quickActionCard(context, "HOD", Icons.supervised_user_circle, const Color(0xFF6A1B9A), "/hod", "Approvals"),
                  
                  // ✅ Tasks card ka color ab Red hai
                  quickActionCard(context, "Tasks", Icons.check_circle, const Color(0xFFB0251A), "/project-task", "Pending"),
                  
                  quickActionCard(context, "Members", Icons.groups, const Color(0xFFD48912), "/add-members", "Team info"),
                ],
              ),

              const SizedBox(height: 25),
              const Text("Performance Overview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),

              /// FEATURE CARDS
              featureCard(context, "Overall Progress", "Track all projects", Icons.analytics, Colors.blue.shade800, 0.7, "/overall-project-progress", "Monitor completion status and milestones."),
              const SizedBox(height: 12),
              featureCard(context, "My Progress", "Check your tasks", Icons.trending_up, Colors.green.shade800, 0.45, "/my-project-progress", "View personal tasks and performance."),
            ],
          ),
        ),
      ),
    );
  }

  /// SLIM CARD WIDGET
  Widget quickActionCard(BuildContext context, String title, IconData icon, Color color, String route, String subtitle) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10), 
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16), 
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                    maxLines: 1,
                  ),
                  Text(
                    subtitle, 
                    style: const TextStyle(color: Colors.white70, fontSize: 8), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FEATURE CARD WIDGET
  Widget featureCard(BuildContext context, String title, String subtitle, IconData icon, Color color, double progress, String route, String description) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 26),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress, backgroundColor: Colors.white24, color: Colors.white, minHeight: 4),
            const SizedBox(height: 10),
            Text(description, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  /// APP DRAWER
  Widget appDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo.shade900),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                const SizedBox(height: 10),
                const Text("Role Management", style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home), 
            title: const Text("Home"), 
            onTap: () => Navigator.pop(context)
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red), 
            title: const Text("Logout"), 
            onTap: () => Navigator.pushReplacementNamed(context, "/")
          ),
        ],
      ),
    );
  }
}