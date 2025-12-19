import 'package:flutter/material.dart';
import 'package:project/Auth/auth.dart';
import 'package:project/Auth/user.dart';
import 'package:project/home.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Base URL for API endpoints - change this to update all API calls
const String baseUrl = 'http://localhost';

void main(){
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Widget initialScreen = Auth(baseUrl: baseUrl);
  bool isLoading = true;

  Future<void> checkAutoLogin() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/data.json');

      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());
        final username = data['username'] ?? '';
        final password = data['password'] ?? '';

        if (username.isNotEmpty && password.isNotEmpty) {
          try {
            final response = await http.get(Uri.parse('$baseUrl/getUsers.php'));
            if (response.statusCode == 200) {
              final temp = jsonDecode(response.body);
              final users = temp.map((e) => User(username: e['username'], password: e['password'])).toList();
              
              for (var user in users) {
                if (user.username == username && user.password == password) {
                  setState(() {
                    initialScreen = Home(user: User(username: username, password: password), baseUrl: baseUrl);
                    isLoading = false;
                  });
                  return;
                }
              }
            }
          } catch (_) {}
        }
      }
    } catch (_) {}
    
    setState(() {
      initialScreen = Auth(baseUrl: baseUrl);
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    checkAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: initialScreen
    );
  }
}