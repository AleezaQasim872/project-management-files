import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/api_service_bgnu.dart';

class OverallProjectProgressScreen extends StatefulWidget {
  const OverallProjectProgressScreen({super.key});

  @override
  State<OverallProjectProgressScreen> createState() =>
      _OverallProjectProgressScreenState();
}

class _OverallProjectProgressScreenState
    extends State<OverallProjectProgressScreen> {
  List projects = [];
  List tasks = [];
  String? selectedProjectId;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  // ================= FETCH PROJECTS =================
  Future<void> fetchProjects() async {
    try {
      final res = await ApiService.get("get_projects.php");
      setState(() => projects = res['projects'] ?? []);
    } catch (e) {
      debugPrint("Failed to fetch projects: $e");
    }
  }

  // ================= FETCH TASKS + MEMBERS =================
  Future<void> fetchTasks(String projectId) async {
    setState(() => loading = true);
    try {
      // 1️⃣ Get tasks from HackDefenders API
      final res = await ApiService.postJson("get_projects_task.php", {
        "project_id": projectId,
      });

      if (res['success'] != true) throw res['message'] ?? "Failed to fetch tasks";

      List tempTasks = res['tasks'] ?? [];

      // 2️⃣ Get assigned members from BGNU/AddMembers API
      final memRes = await ApiService.post("show_project_members.php", {
        "project_id": projectId,
      });

      List projectMembers = [];
      if (memRes['success'] == true) {
        projectMembers = memRes['members'] ?? [];
      }

      // 3️⃣ Assign members to each task
      for (var t in tempTasks) {
        // You can customize to show only members for that specific task if your API supports task_id
        t['members'] = projectMembers.isNotEmpty
            ? projectMembers.map((m) => m['name']).join(", ")
            : "No members assigned";
      }

      setState(() => tasks = tempTasks);
    } catch (e) {
      debugPrint("Failed to fetch tasks: $e");
      setState(() => tasks = []);
    } finally {
      setState(() => loading = false);
    }
  }

  // ================= UPDATE STATUS =================
  Future<void> updateStatus(String taskId, String status) async {
    try {
      final res = await ApiService.postJson("update_task_status.php", {
        "task_id": taskId,
        "user_id": "1",
        "status": status,
      });

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Status updated")),
        );
        if (selectedProjectId != null) fetchTasks(selectedProjectId!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${res['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating status: $e")),
      );
    }
  }

  // ================= STATUS COLOR =================
  Color statusColor(String? status) {
    switch ((status ?? "pending").toLowerCase()) {
      case "completed":
        return Colors.green;
      case "in_process":
        return Colors.orange;
      case "pending":
      default:
        return Colors.blueGrey;
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Overall Project Progress"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              value: selectedProjectId,
              hint: const Text("Select Project"),
              items: projects.map<DropdownMenuItem<String>>((p) {
                return DropdownMenuItem(
                  value: p['id'].toString(),
                  child: Text(p['project_name']),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => selectedProjectId = val);
                fetchTasks(val!);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : tasks.isEmpty
                    ? const Center(
                        child: Text(
                          "No tasks assigned",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, i) {
                          final t = tasks[i];
                          final members = t['members'] ?? "No members assigned";

                          return Card(
                            margin: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t['task'] ?? "No Title",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 6),
                                  Text("Members: $members"),
                                  Text(
                                      "Due: ${t['due_date']} ${t['due_time']}"),
                                  const SizedBox(height: 10),
                                  DropdownButtonFormField<String>(
                                    value: t['status'] ?? "pending",
                                    items: const [
                                      DropdownMenuItem(
                                          value: "pending",
                                          child: Text("Pending")),
                                      DropdownMenuItem(
                                          value: "in_process",
                                          child: Text("In Process")),
                                      DropdownMenuItem(
                                          value: "completed",
                                          child: Text("Completed")),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        updateStatus(
                                            t['task_id'].toString(), val);
                                      }
                                    },
                                    decoration: const InputDecoration(
                                      labelText: "Status",
                                      border: OutlineInputBorder(),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}