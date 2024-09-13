

import 'package:do_to_app1/screens/add_to_do.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For encoding data to JSON format

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List items = [];
  Future<void> fetchdata() async {
    const url = "https://api.nstack.in/v1/todos?page=1&limit=10";
// ignore: unused_local_variable
    final uri = Uri.parse(url);
// ignore: unused_local_variable
    final responce = await http.get(uri);
    if (responce.statusCode == 200) {
      final json = jsonDecode(
        responce.body,
      ) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    } else {}
  }

  @override
  void initState() {
    fetchdata();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text("TO DO ", style: TextStyle(color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AddToDo()));
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: RefreshIndicator(
          onRefresh: fetchdata,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text("${index + 1}"),
                  ),
                  title: Text(
                    item["title"],
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(item["description"],
                      style: TextStyle(color: Colors.white)),
                );
              }),
        ),
      ),
    );
  }
}
