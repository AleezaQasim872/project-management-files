import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  List tasks = [];
  bool isLoading = true;
  String userId = '';

  @override
  void initState() {
    super.initState();
    loadUserAndTasks();
  }

  Future<void> loadUserAndTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id') ?? '';
    if (userId.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("https://hackdefenders.com/api/get_participant_tasks.php?user_id=$userId"),
      );

      if (response.body.isEmpty) throw Exception("Empty response from server");

      final data = jsonDecode(response.body);

      if (data['status'] == true && data['data'] is List) {
        setState(() {
          tasks = data['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          tasks = [];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
      setState(() {
        tasks = [];
        isLoading = false;
      });
    }
  }

  Future<void> submitTask(String taskId) async {
    try {
      final response = await http.post(
        Uri.parse("https://hackdefenders.com/api/submit_task.php"),
        body: {
          'user_id': userId,
          'task_id': taskId,
        },
      );

      if (response.body.isEmpty) throw Exception("Empty response from server");

      final data = jsonDecode(response.body);

      if (data['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task submitted successfully!"), backgroundColor: Colors.green),
        );
        // Refresh tasks list
        loadUserAndTasks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Task submission failed"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Tasks"), backgroundColor: Colors.deepPurple),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(child: Text("No tasks assigned yet"))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    bool isPending = task['status'] == 'pending';
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(task['task'] ?? 'Unnamed Task'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Due: ${task['due_date']} ${task['due_time']}"),
                            Text("Status: ${task['status']}"),
                            if (task['description'] != null) Text("Description: ${task['description']}"),
                          ],
                        ),
                        trailing: isPending
                            ? ElevatedButton(
                                onPressed: () => submitTask(task['id'].toString()),
                                child: const Text("Submit"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(70, 35),
                                ),
                              )
                            : const Text("Submitted", style: TextStyle(color: Colors.green)),
                      ),
                    );
                  },
                ),
    );
  }
}