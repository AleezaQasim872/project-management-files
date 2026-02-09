import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../services/api_service.dart';
import '../../services/notification_service_mobile.dart';

class ProjectTaskScreen extends StatefulWidget {
  const ProjectTaskScreen({super.key});

  @override
  State<ProjectTaskScreen> createState() => _ProjectTaskScreenState();
}

class _ProjectTaskScreenState extends State<ProjectTaskScreen> {
  List projects = [];
  List tasks = [];

  String? selectedProjectId;
  String? selectedProjectName;

  final TextEditingController taskController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay selectedTime = const TimeOfDay(hour: 23, minute: 59);

  bool loadingTasks = false;
  bool addingTask = false;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  Future<void> fetchProjects() async {
    try {
      final res = await ApiService.get("get_projects.php");
      setState(() {
        projects = res['projects'] ?? [];
      });
    } catch (e) {
      debugPrint("Error fetching projects: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch projects")),
      );
    }
  }

  Future<void> fetchTasks() async {
    if (selectedProjectId == null) return;

    setState(() => loadingTasks = true);

    try {
      final res = await ApiService.postJson("get_projects_task.php", {
        "project_id": selectedProjectId!,
      });

      if (res['success'] == true) {
        setState(() {
          tasks = res['tasks'] ?? [];
        });
      } else {
        setState(() => tasks = []);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "No tasks found")),
        );
      }
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
      setState(() => tasks = []);
    } finally {
      setState(() => loadingTasks = false);
    }
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (time != null) setState(() => selectedTime = time);
  }

  Future<void> submitTask() async {
    if (selectedProjectId == null ||
        taskController.text.trim().isEmpty ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() => addingTask = true);

    try {
      final res = await ApiService.postJson(
        "add_project_task.php",
        {
          "project_id": selectedProjectId!,
          "task": taskController.text.trim(),
          "due_date":
              "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
          "due_time":
              "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}"
        },
      );

      if (res['success'] == true) {
        final taskText = taskController.text.trim();
        final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        // ✅ Immediate notification
        await NotificationService().showNotification(
          id: notificationId,
          title: "New Task Assigned",
          body: taskText,
        );

        // ✅ Scheduled notification
        final scheduledDateTime = tz.TZDateTime.from(
          DateTime(
            selectedDate!.year,
            selectedDate!.month,
            selectedDate!.day,
            selectedTime.hour,
            selectedTime.minute,
          ),
          tz.local,
        );

        await NotificationService().scheduleNotification(
          id: notificationId + 1,
          title: "Task Due",
          body: taskText,
          scheduledTime: scheduledDateTime,
        );

        taskController.clear();
        selectedDate = null;
        selectedTime = const TimeOfDay(hour: 23, minute: 59);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "Task added")),
        );

        fetchTasks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "Task add failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network/Error: $e")),
      );
    } finally {
      setState(() => addingTask = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Project Tasks"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROJECT DROPDOWN
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Select Project",
                  border: InputBorder.none,
                ),
                value: selectedProjectId,
                items: projects.map<DropdownMenuItem<String>>((p) {
                  return DropdownMenuItem(
                    value: p['id'].toString(),
                    child: Text(p['project_name']),
                  );
                }).toList(),
                onChanged: (val) {
                  final proj = projects.firstWhere((e) => e['id'].toString() == val);
                  setState(() {
                    selectedProjectId = val;
                    selectedProjectName = proj['project_name'];
                    tasks.clear();
                  });
                  fetchTasks();
                },
              ),
            ),

            const SizedBox(height: 16),

            // TASK FIELD
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: "Task Description",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // DATE & TIME PICKERS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      selectedDate == null
                          ? "Select Date"
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade400,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(selectedTime.format(context)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade400,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ADD BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addingTask ? null : submitTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: addingTask
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Task", style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Assigned Tasks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            loadingTasks
                ? const Center(child: CircularProgressIndicator())
                : tasks.isEmpty
                    ? const Center(
                        child: Text("No tasks found",
                            style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final t = tasks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: ListTile(
                              title: Text(t['task'],
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("Due: ${t['due_date']} at ${t['due_time']}"),
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurple,
                                child: const Icon(Icons.task_alt, color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
