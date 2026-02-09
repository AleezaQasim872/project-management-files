import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool showPassword = false;

  Future<void> loginAdmin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      final res = await http.post(
        Uri.parse("https://bgnu.space/api/submit_login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "login": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "cellno": ""
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['status'] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_name', data['user_full_name'] ?? 'Admin');
        await prefs.setBool('isLoggedIn', true);

        if (!mounted) return;
        // ✅ Dashboard ki bajaye Role Selection par bhejen
        Navigator.pushReplacementNamed(context, '/select-role');
      } else {
        throw Exception(data['message'] ?? "Login Failed");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.indigo.shade600],
            begin: Alignment.topCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Icon(Icons.admin_panel_settings, size: 90, color: Colors.white),
              const SizedBox(height: 20),
              const Text("Admin Login", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 50),
              Container(
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: "Username/Email", prefixIcon: Icon(Icons.person)),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => showPassword = !showPassword),
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : loginAdmin,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade900, foregroundColor: Colors.white),
                          child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("LOGIN"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}