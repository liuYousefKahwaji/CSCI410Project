import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:project/Auth/AuthToggle.dart';
import 'package:project/Auth/AuthField.dart';
import 'package:project/Auth/user.dart';
import 'package:project/home.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Auth extends StatefulWidget {
  final String baseUrl;
  const Auth({required this.baseUrl, super.key});

  @override
  State<Auth> createState() => _AuthState();
}

TextEditingController usernameController = TextEditingController();
TextEditingController passwordController = TextEditingController();
bool login = true;
List<User> users = [];
List temp = [];

Future<void> getUsers(String baseUrl) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/getUsers.php'));
    if (response.statusCode == 200) {
      temp = jsonDecode(response.body);
      users = temp.map((e) => User(username: e['username'], password: e['password'])).toList();
    }
  } catch (_) {}
}

Future<void> insertUser(String baseUrl, User u) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/insertUser.php'),
      body: jsonEncode({'username': u.username, 'password': u.password}),
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      getUsers(baseUrl);
    }
  } catch (_) {}
}

Future<void> _writeData({required User user}) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/data.json');

  final data = {
    'isLightTheme': true,
    'username': user.username,
    'password': user.password
  };
  await file.writeAsString(jsonEncode(data));
}

class _AuthState extends State<Auth> {
  @override
  void initState() {
    super.initState();
    getUsers(widget.baseUrl);
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> validateUser(String username, String password) async {
      User u = User(username: username, password: password);
      if(login==false){
        for (var user in users) {
          if (user.username==u.username) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Username $username already exists.')));
            return false;
          }
        }
        await insertUser(widget.baseUrl, u);
        await _writeData(user: u);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User $username registered successfully.')));
        return true;
      }
      List<String> msg = ['Incorrect username or password.', 'Login successful. Welcome $username!'];
      for (var user in users) {
        if (user.username==u.username && user.password==u.password) {
          await _writeData(user: u);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg[1])));
          return true;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg[0])));
      return false;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                Image.asset('lib/assets/appIcon.png', height: MediaQuery.of(context).size.height * 0.35, width: MediaQuery.of(context).size.height * 0.35,),
                AuthToggle(
                  login: login,
                  onToggle: (t) => setState(() {
                    login = t;
                  }),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                AuthField(
                  label: 'Username',
                  hint: 'Enter your username',
                  controller: usernameController,
                  icon: Icon(Icons.person_outline, color: Colors.black),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                AuthField(label: 'Password', hint: 'Enter your password', isPassword: true, controller: passwordController, icon: Icon(Icons.lock_outline)),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                Center(
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.5,
                    decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(16)),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.pressed)) {
                            return const Color.fromARGB(255, 33, 33, 33);
                          }
                          if (states.contains(WidgetState.hovered)) {
                            return const Color.fromARGB(255, 9, 9, 9);
                          }
                          return Colors.black;
                        }),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0))),
                        overlayColor: WidgetStateProperty.all(Colors.white10),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                      ),
                      onPressed: () async {
                        if(await validateUser(usernameController.text, passwordController.text)){
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home(user: User(username: usernameController.text, password: passwordController.text), baseUrl: widget.baseUrl), settings: RouteSettings(arguments: User(username: usernameController.text, password: passwordController.text),),));
                          usernameController.clear();
                          passwordController.clear();
                        }
                      },
                      child: Text(login ? 'Sign in' : 'Sign up'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
