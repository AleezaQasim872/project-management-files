import 'package:flutter/material.dart';
import '../../services/api_service_bgnu.dart';
import 'user_tasks_screen.dart';

class MyProjectProgressScreen extends StatefulWidget {
  const MyProjectProgressScreen({super.key});

  @override
  State<MyProjectProgressScreen> createState() =>
      _MyProjectProgressScreenState();
}

class _MyProjectProgressScreenState extends State<MyProjectProgressScreen> {
  List<dynamic> students = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    setState(() => isLoading = true);
    try {
      final res = await ApiServiceBGNU.getStudents();
      setState(() => students = res);
    } catch (e) {
      setState(() => students = []);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching students: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("Students Progress"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
              ? const Center(
                  child: Text("No students found",
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.indigo,
                          child: Text(
                            (student['user_full_name'] ?? 'U')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        title: Text(student['user_full_name'] ?? 'No Name'),
                        subtitle: Text(student['rollno'] ?? ''),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text("Tasks"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserTasksScreen(
                                  rollNo: student['rollno'] ?? '',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}