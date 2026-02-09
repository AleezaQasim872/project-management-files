import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyProjectsScreen extends StatefulWidget {
  final String userId; // ✅ add this

  const MyProjectsScreen({super.key, required this.userId});

  @override
  State<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen> {
  List projects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://hackdefenders.com/api/get_participant_projects.php?user_id=${widget.userId}",
        ),
      );

      if (response.body.isEmpty) throw Exception("Empty response from server");

      final data = jsonDecode(response.body);

      if (data['status'] == true && data['data'] is List) {
        setState(() {
          projects = data['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          projects = [];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Project error: $e");
      setState(() {
        projects = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Projects"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : projects.isEmpty
              ? const Center(child: Text("No projects assigned"))
              : ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final p = projects[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(p['project_name'] ?? 'Unnamed Project'),
                        subtitle: Text(p['description'] ?? ''),
                      ),
                    );
                  },
                ),
    );
  }
}