import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/api_service_bgnu.dart';

class AddMembersScreen extends StatefulWidget {
  const AddMembersScreen({super.key});

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  List projects = [];
  List students = [];
  List members = [];

  String? selectedProjectId;
  String? selectedStudentRoll;

  bool loadingProjects = true;
  bool loadingStudents = true;
  bool loadingMembers = false;

  @override
  void initState() {
    super.initState();
    fetchProjects();
    fetchStudents();
  }

  /// 🔹 FETCH PROJECTS
  Future<void> fetchProjects() async {
    try {
      final res = await ApiService.get("get_projects.php");
      setState(() {
        projects = res['projects'] ?? [];
        loadingProjects = false;
      });
    } catch (e) {
      setState(() => loadingProjects = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching projects")),
      );
    }
  }

  /// 🔹 FETCH STUDENTS (BGNU)
  Future<void> fetchStudents() async {
    try {
      final res = await ApiServiceBGNU.getStudents();
      setState(() {
        students = res;
        loadingStudents = false;
      });
    } catch (e) {
      setState(() => loadingStudents = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching students")),
      );
    }
  }

  /// 🔹 SAVE MEMBER
  Future<void> saveMember() async {
    if (selectedProjectId == null || selectedStudentRoll == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select project & student")),
      );
      return;
    }

    try {
      final res = await ApiService.post(
        "add_project_member.php",
        {
          "project_id": selectedProjectId!,
          "roll_no": selectedStudentRoll!,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "Member added")),
      );

      showMembers(); // Refresh members list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save member")),
      );
    }
  }

  /// 🔹 SHOW MEMBERS
  Future<void> showMembers() async {
    if (selectedProjectId == null) return;

    setState(() => loadingMembers = true);

    try {
      final res = await ApiService.post(
        "show_project_members.php",
        {"project_id": selectedProjectId!},
      );

      debugPrint("RAW RESPONSE: $res");

      if (res['success'] == true) {
        setState(() {
          members = res['members'] ?? [];
        });
      } else {
        setState(() => members = []);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "No members found")),
        );
      }
    } catch (e) {
      debugPrint("SHOW MEMBERS ERROR: $e");
      setState(() => members = []);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch members")),
      );
    } finally {
      setState(() => loadingMembers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Add Members"),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        shadowColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// PROJECT DROPDOWN
            loadingProjects
                ? const LinearProgressIndicator(color: Colors.deepPurple)
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<String>(
                      value: selectedProjectId,
                      decoration: const InputDecoration(
                        labelText: "Select Project",
                        border: InputBorder.none,
                      ),
                      items: projects.map<DropdownMenuItem<String>>((p) {
                        return DropdownMenuItem<String>(
                          value: p['id'].toString(),
                          child: Text(p['project_name']),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() {
                          selectedProjectId = v;
                          members.clear();
                        });
                      },
                    ),
                  ),
            const SizedBox(height: 12),

            /// STUDENT DROPDOWN
            loadingStudents
                ? const LinearProgressIndicator(color: Colors.deepPurple)
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<String>(
                      value: selectedStudentRoll,
                      decoration: const InputDecoration(
                        labelText: "Select Student",
                        border: InputBorder.none,
                      ),
                      items: students.map<DropdownMenuItem<String>>((s) {
                        return DropdownMenuItem<String>(
                          value: s['rollno'],
                          child: Text(s['user_full_name']),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() => selectedStudentRoll = v);
                      },
                    ),
                  ),
            const SizedBox(height: 20),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: saveMember,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      "SAVE",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: showMembers,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      "SHOW",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// MEMBERS LIST
            Expanded(
              child: loadingMembers
                  ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
                  : members.isEmpty
                      ? const Center(
                          child: Text(
                            "No members found",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: members.length,
                          itemBuilder: (context, i) {
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.deepPurple,
                                  child: const Icon(Icons.person, color: Colors.white),
                                ),
                                title: Text(
                                  members[i]['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text("Roll No: ${members[i]['roll_no']}"),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}