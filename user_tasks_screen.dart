import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'submit_task_screen.dart';

class UserTasksScreen extends StatefulWidget {
  final String rollNo;
  const UserTasksScreen({super.key, required this.rollNo});

  @override
  State<UserTasksScreen> createState() => _UserTasksScreenState();
}

class _UserTasksScreenState extends State<UserTasksScreen> {
  List<dynamic> tasks = [];
  bool isLoading = false;
  String? projectName;

  @override
  void initState() {
    super.initState();
    fetchTasksForStudent();
  }

  Future<void> fetchTasksForStudent() async {
    setState(() => isLoading = true);

    try {
      // 1️⃣ Get student's project
      final projectRes = await ApiService.postJson(
        "get_student_project.php",
        {"roll_no": widget.rollNo},
      );

      if (projectRes['success'] != true) {
        setState(() => tasks = []);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(projectRes['message'] ?? "No project assigned")));
        return;
      }

      final projectId = int.parse(projectRes['project_id'].toString());

      // 2️⃣ Fetch tasks assigned to that project
      final taskRes = await ApiService.postJson(
        "get_projects_task.php",
        {"project_id": projectId},
      );

      if (taskRes['success'] == true) {
        setState(() {
          tasks = taskRes['tasks'] ?? [];
          projectName = taskRes['project_name'] ?? "Project Tasks";
        });
      } else {
        setState(() => tasks = []);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(taskRes['message'] ?? "No tasks found")));
      }
    } catch (e) {
      setState(() => tasks = []);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to load tasks: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text(projectName ?? "Tasks"),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(
                  child: Text(
                  "No tasks assigned",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final t = tasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        title: Text(t['task']),
                        subtitle: Text("Due: ${t['due_date']} at ${t['due_time']}"),
                        leading: const Icon(Icons.task_alt, color: Colors.purple),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text("Submit"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SubmitTaskScreen(
                                  taskId: int.parse(t['id'].toString()),
                                
                                  taskName: t['task']??'No Title',
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