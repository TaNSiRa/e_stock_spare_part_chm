import 'package:e_stock_spare_part_chm/Page/loginpage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Stock Spare Part Chemical Controller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // set the home to LoginScreen
    );
  }
}
