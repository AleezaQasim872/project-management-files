import 'package:flutter/material.dart';
import 'admin_login_screen.dart';
import 'participant_login_screen.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade900, Colors.indigo.shade600],
          ),
        ),
        // ✅ SingleChildScrollView add kiya gaya hai taake overflow error khatam ho
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Icon(Icons.account_balance_rounded, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                "UNIVERSITY STORE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Text(
                "Management System",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 50), // Spacer ki jagah fixed height
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Login As",
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    _buildSelectionCard(
                      context,
                      title: "Admin Portal",
                      subtitle: "Inventory & Requests Management",
                      icon: Icons.admin_panel_settings_rounded,
                      color: Colors.indigo.shade800,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildSelectionCard(
                      context,
                      title: "Participant Login",
                      subtitle: "Project Tasks & Progress",
                      icon: Icons.group_rounded,
                      color: Colors.deepPurple.shade700,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ParticipantLoginScreen()),
                      ),
                    ),
                    // Neeche thori extra space taake keyboard ya screen edge se na takraye
                    const SizedBox(height: 100), 
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}