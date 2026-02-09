import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SubmitTaskScreen extends StatefulWidget {
  final int taskId;
  final String taskName;

  const SubmitTaskScreen({
    super.key,
    required this.taskId,
    required this.taskName,
  });

  @override
  State<SubmitTaskScreen> createState() => _SubmitTaskScreenState();
}

class _SubmitTaskScreenState extends State<SubmitTaskScreen> {
  String status = "in_process";
  TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;

  Future<void> submitTask() async {
    if (widget.taskId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid task ID")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await ApiService.postJson("submit_task.php", {
        "task_id": widget.taskId,
        "status": status,
        "description": descriptionController.text,
      });

      if (res['status'] == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res['message'] ?? "Submitted")));
        Navigator.pop(context); // Go back after submission
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res['message'] ?? "Failed")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Submit Task: ${widget.taskName}"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Status:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: status,
              items: const [
                DropdownMenuItem(value: "in_process", child: Text("In Process")),
                DropdownMenuItem(value: "completed", child: Text("Completed")),
              ],
              onChanged: (val) {
                if (val != null) setState(() => status = val);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Description / Notes",
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Task", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}