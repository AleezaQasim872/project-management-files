import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../dashboard/participant_dashboard.dart';

class ParticipantLoginScreen extends StatefulWidget {
  const ParticipantLoginScreen({super.key});

  @override
  State<ParticipantLoginScreen> createState() =>
      _ParticipantLoginScreenState();
}

class _ParticipantLoginScreenState extends State<ParticipantLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final loginValue = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      /// 1️⃣ BGNU LOGIN
      final res = await http.post(
        Uri.parse("https://bgnu.space/api/submit_login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "login": loginValue,
          "password": password,
          "cellno": ""
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode != 200 || data['status'] != true) {
        throw Exception(data['message'] ?? "Login failed");
      }

      /// 2️⃣ USER DATA
      final email = data['email'] ?? loginValue;
      final name = data['user_full_name'] ?? 'User';

      /// 3️⃣ SYNC USER TO HACKDEFENDERS
      final syncRes = await http.post(
        Uri.parse("https://hackdefenders.com/api/sync_participant.php"),
        body: {
          'email': email,
          'name': name,
        },
      );

      if (syncRes.body.isEmpty) {
        throw Exception("Empty sync response");
      }

      final syncData = jsonDecode(syncRes.body);

      if (syncData['status'] != true) {
        throw Exception("User sync failed");
      }

      final String userId = syncData['user_id'].toString();

      /// 4️⃣ SAVE TO SHARED PREFERENCES
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      await prefs.setBool('isLoggedIn', true);

      /// 5️⃣ NAVIGATE
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ParticipantDashboard(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Icon(Icons.lock_person, size: 90, color: Colors.white),
            const SizedBox(height: 15),
            const Text(
              "Participant Login",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(35)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? "Email required" : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(showPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() => showPassword = !showPassword);
                            },
                          ),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? "Password required" : null,
                      ),
                      const SizedBox(height: 35),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  "LOGIN",
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}