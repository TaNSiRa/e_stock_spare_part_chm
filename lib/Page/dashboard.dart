import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:e_stock_spare_part_chm/Page/loginpage.dart';
import 'package:e_stock_spare_part_chm/Page/stocksparepart.dart';
import 'package:e_stock_spare_part_chm/Page/HistorySparePart.dart';

class DashboardScreen extends StatefulWidget {
  final User user; // Add user as a property to store the logged-in user
  DashboardScreen({required this.user});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    String currentTime = DateFormat('HH:mm').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'THAI PARKERIZING CO., LTD.',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              'User: ${widget.user.UserName}', // Display the user's name here
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              currentTime,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          IconButton(
            onPressed: () {
              // Handle logout button press
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
            icon: Icon(Icons.logout),
            color: Colors.white,
          ),
        ],
      ),
      body:
          _selectedIndex == 0 ? StockSparePartsPage() : HistorySparePartsPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: 'Stock Spare Parts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History Spare Parts',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
