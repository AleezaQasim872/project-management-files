import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestItemsScreen extends StatefulWidget {
  const RequestItemsScreen({super.key});

  @override
  State<RequestItemsScreen> createState() => _RequestItemsScreenState();
}

class _RequestItemsScreenState extends State<RequestItemsScreen> {
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;
  bool isRequesting = false;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
    });

    try {
      final res = await ApiService.get("get_items.php");
      setState(() {
        items = List<Map<String, dynamic>>.from(res["items"] ?? []);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching items: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> requestItem(dynamic itemId) async {
    // Prevent multiple simultaneous requests
    if (isRequesting) return;

    setState(() => isRequesting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId") ?? "0";

      final res = await ApiService.post(
        "request_item.php",
        {
          "item_id": itemId.toString(),
          "user_id": userId,
        },
      );

      final message = res["message"] ??
          (res["success"] == true ? "Request sent" : "Request failed");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      // Optionally refresh items or user requests after a successful request
      if (res["success"] == true) {
        await fetchItems();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending request: $e")),
      );
    } finally {
      setState(() => isRequesting = false);
    }
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final icon = item['icon'];
    final name = item['name'] ?? 'Unnamed';
    final id = item['id'];

    final imageUrl = (icon != null && icon.toString().isNotEmpty)
        ? Uri.encodeFull(
            "https://hackdefenders.com/assets/icons/${icon.toString()}")
        : null;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.indigo,
                      ),
                    )
                  : const Icon(
                      Icons.inventory,
                      size: 50,
                      color: Colors.indigo,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isRequesting ? null : () => requestItem(id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isRequesting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Request"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Items"),
        backgroundColor: Colors.indigo,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? RefreshIndicator(
                  onRefresh: fetchItems,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(child: Text("No items available")),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchItems,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      itemCount: items.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildItemCard(item);
                      },
                    ),
                  ),
                ),
    );
  }
}