import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dashboard.dart';

class User {
  final int Id;
  final String UserName;
  final String Section;
  final String Branch;
  final int Roleid;

  User({
    required this.Id,
    required this.UserName,
    required this.Section,
    required this.Branch,
    required this.Roleid,
  });
}

User? currentUser;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set default value for username
    // _usernameController.text = 'sirawit';
    // _passwordController.text = '1';
  }

  Future<void> _login() async {
    setState(() {});

    try {
      final response = await http.post(
        Uri.parse('http://172.23.10.51:3005/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success']) {
          // Ensure responseData['user'] is not null and contains the expected fields
          if (responseData['user'] != null &&
              responseData['user']['Id'] != null &&
              responseData['user']['Name'] != null &&
              responseData['user']['Section'] != null &&
              responseData['user']['Branch'] != null &&
              responseData['user']['Roleid'] != null) {
            print('Received user data:');
            print('Id: ${responseData['user']['Id']}');
            print('Name: ${responseData['user']['Name']}');
            print('Section: ${responseData['user']['Section']}');
            print('Branch: ${responseData['user']['Branch']}');
            print('Roleid: ${responseData['user']['Roleid']}');
            currentUser = User(
              Id: responseData['user']['Id'],
              UserName: responseData['user']['Name'],
              Section: responseData['user']['Section'],
              Branch: responseData['user']['Branch'],
              Roleid: responseData['user']['Roleid'],
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => DashboardScreen(user: currentUser!)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid user data received')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid username or password')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error 1: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('An error 2: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error 3: $e')),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueAccent, Color.fromARGB(255, 134, 231, 236)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 10.0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 150.0,
                      width: 150.0,
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'E-Stock Spare Part Chemical Controller',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 40.0,
                      width: 200.0,
                      child: TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 40.0,
                      width: 200.0,
                      child: TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 50.0,
                          vertical: 15.0,
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
