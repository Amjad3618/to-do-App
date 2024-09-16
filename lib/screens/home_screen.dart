import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_to_do.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
} 

class _HomeScreenState extends State<HomeScreen> {
  List _todoItems = [];
  bool _isLoading = true;

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    const url = "https://api.nstack.in/v1/todos?page=1&limit=10";
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List fetchedItems = jsonData['items'] as List;
        setState(() {
          _todoItems = fetchedItems;
          _isLoading = false;
        });
        print("Fetched items: $_todoItems");
      } else {
        _showErrorSnackbar('Failed to load data');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorSnackbar('An error occurred: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> deleteById(String id) async {
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);

    try {
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        setState(() {
          _todoItems.removeWhere((item) => item['_id'] == id);
        });
        print("Item with ID $id deleted successfully");
      } else {
        print("Failed to delete item. Status code: ${response.statusCode}");
        _showErrorSnackbar("Failed to delete the item");
      }
    } catch (e) {
      print("An error occurred: $e");
      _showErrorSnackbar("An error occurred while deleting the item");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: const Text("To Do", style: TextStyle(color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddToDo()),
          ).then((_) => _fetchData()); // Refresh the list after adding a new item
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: RefreshIndicator(
          onRefresh: _fetchData,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _todoItems.isEmpty
                  ? const Center(
                      child: Text(
                        "No items to display",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _todoItems.length,
                      itemBuilder: (context, index) {
                        final item = _todoItems[index];
                        final itemId = item['_id']?.toString() ?? '';

                        return ListTile(
                          leading: CircleAvatar(
                            child: Text("${index + 1}"),
                          ),
                          title: Text(
                            item['title'] ?? 'No Title',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            item['description'] ?? 'No Description',
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              if (itemId.isNotEmpty) {
                                deleteById(itemId);
                              } else {
                                _showErrorSnackbar('Invalid item ID for deletion');
                              }
                            },
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}