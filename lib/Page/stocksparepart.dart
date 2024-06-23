// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // นำเข้าแพ็กเกจสำหรับจัดการวันที่และเวลา
import 'package:e_stock_spare_part_chm/Page/loginpage.dart';
import 'package:lottie/lottie.dart';

String userName = currentUser?.UserName ?? 'Unknown';
String _searchQuery = '';

class StockSparePartsPage extends StatefulWidget {
  @override
  _StockSparePartsPageState createState() => _StockSparePartsPageState();
}

class _StockSparePartsPageState extends State<StockSparePartsPage> {
  Future<List<Map<String, dynamic>>> _fetchData() async {
    final response = await http.get(Uri.parse('http://172.23.10.51:3005/Mat'));
    if (response.statusCode == 200) {
      return json.decode(response.body).cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _showImportExportDialog(
      BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Action'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose an action to perform:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close Dialog
                      _handleImport(context, data);
                    },
                    child: Text('Import Part'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close Dialog
                      _handleExport(context, data);
                    },
                    child: Text('Export Part'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close Dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _handleImport(BuildContext context, Map<String, dynamic> data) {
    TextEditingController quantityController = TextEditingController();
    TextEditingController remarkController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Import Part'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mat: ${data['Mat']}'),
              Text('Name: ${data['Name']}'),
              Text('Quantity: ${data['Quantity']}'),
              Text('SafetyStock: ${data['SafetyStock']}'),
              SizedBox(height: 20), // เพิ่มระยะห่าง
              TextField(
                controller: remarkController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: 'From supplier:'),
              ),
              SizedBox(height: 10), // เพิ่มระยะห่าง
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: 'Enter quantity to import:'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close Dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                int importedQuantity =
                    int.tryParse(quantityController.text) ?? 0;
                String remark = remarkController.text;

                if (importedQuantity > 0 &&
                    importedQuantity != 0 &&
                    remark.isNotEmpty) {
                  int currentQuantity = data['Quantity'] ?? 0;
                  int newQuantity = currentQuantity + importedQuantity;

                  print(
                      'Imported $importedQuantity to ${data['Mat']}. New quantity: $newQuantity');

                  bool success =
                      await _updateQuantity(data['Mat'], newQuantity);
                  if (success) {
                    setState(() {
                      data['Quantity'] = newQuantity;
                    });

                    DateTime now = DateTime.now();
                    String formattedDate =
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

                    bool logSuccess = await _logImport(
                        data['Mat'],
                        importedQuantity,
                        remark,
                        formattedDate,
                        userName,
                        data['Name']);

                    if (logSuccess) {
                      Navigator.of(context).pop(); // Close Dialog
                      _showSuccessDialog(context, 'Import success');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to log import.'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update quantity.'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Please enter a valid quantity and remark.'),
                    ),
                  );
                }
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _handleExport(BuildContext context, Map<String, dynamic> data) {
    TextEditingController quantityController = TextEditingController();
    TextEditingController remarkController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Export Part'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mat: ${data['Mat']}'),
              Text('Name: ${data['Name']}'),
              Text('Quantity: ${data['Quantity']}'),
              Text('SafetyStock: ${data['SafetyStock']}'),
              SizedBox(height: 20), // เพิ่มระยะห่าง
              TextField(
                controller: remarkController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: 'To Customer:'),
              ),
              SizedBox(height: 10), // เพิ่มระยะห่าง
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: 'Enter quantity to Export:'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close Dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                int exportedQuantity =
                    int.tryParse(quantityController.text) ?? 0;
                int currentQuantity = data['Quantity'] ?? 0;
                String remark = remarkController.text;

                if (exportedQuantity > 0 &&
                    exportedQuantity <= currentQuantity) {
                  int newQuantity = currentQuantity - exportedQuantity;
                  print(
                      'Exported $exportedQuantity from ${data['Mat']}. New quantity: $newQuantity');

                  bool success =
                      await _updateQuantity(data['Mat'], newQuantity);
                  if (success) {
                    setState(() {
                      data['Quantity'] = newQuantity;
                    });

                    DateTime now = DateTime.now();
                    String formattedDate =
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

                    bool logSuccess = await _logExport(
                        data['Mat'],
                        exportedQuantity,
                        remark,
                        formattedDate,
                        userName,
                        data['Name']);

                    if (logSuccess) {
                      Navigator.of(context).pop(); // Close Dialog
                      _showSuccessDialog(context, 'Export success');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to log import.'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update quantity.'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Please enter a valid quantity and remark.'),
                    ),
                  );
                }
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/animations/success.json',
                  width: 150, height: 150),
              SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close Dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _updateQuantity(String mat, int newQuantity) async {
    final response = await http.put(
      Uri.parse('http://172.23.10.51:3005/Mat/$mat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'Quantity': newQuantity,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update quantity: ${response.body}');
      return false;
    }
  }

  Future<bool> _logImport(String mat, int quantity, String remark, String date,
      String userName, String Name) async {
    final response = await http.post(
      Uri.parse('http://172.23.10.51:3005/E_StockLog'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'Mat': mat,
        'Quantity': quantity,
        'Remark': remark,
        'UserName': userName,
        'Date': date,
        'Name': Name,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to log import: ${response.body}');
      return false;
    }
  }

  Future<bool> _logExport(String mat, int quantity, String remark, String date,
      String userName, String Name) async {
    final response = await http.post(
      Uri.parse('http://172.23.10.51:3005/E_StockLogExport'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'Mat': mat,
        'Quantity': quantity,
        'Remark': remark,
        'UserName': userName,
        'Date': date,
        'Name': Name,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to log Export: ${response.body}');
      return false;
    }
  }

  void showImageDialog(BuildContext context, String imagePath,
      String matReference, String NameReference) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                imagePath,
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 5),
              Text(
                '$matReference' + ' ' + '$NameReference',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'E-Stock Spare Part Chemical Controller',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0.0), // ระยะห่างด้านบน
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return ListView(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        dataRowHeight: 40,
                        columns: [
                          DataColumn(
                            label: Text('No',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Image',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Mat',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Name',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Quantity',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('SafetyStock',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Edit Data',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ],
                        rows: snapshot.data!
                            .asMap()
                            .entries
                            .map<DataRow>((entry) {
                          final int index = entry.key;
                          final Map<String, dynamic> data = entry.value;

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  (index + 1).toString(),
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              DataCell(
                                GestureDetector(
                                  onTap: () {
                                    showImageDialog(
                                        context,
                                        'assets/images/${data['Mat']}.jpg',
                                        data['Mat'],
                                        '${data['Name']}');
                                  },
                                  child: data['Mat'] != null
                                      ? Image.asset(
                                          'assets/images/${data['Mat']}.jpg',
                                          width: 50,
                                          height: 50,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(Icons.broken_image);
                                          },
                                        )
                                      : Text('No image'),
                                ),
                              ),
                              DataCell(Text(data['Mat'] ?? 'No data',
                                  style: TextStyle(fontSize: 12))),
                              DataCell(Text(data['Name'] ?? 'No data',
                                  style: TextStyle(fontSize: 12))),
                              DataCell(
                                Text(data['Quantity']?.toString() ?? 'No data',
                                    style: TextStyle(fontSize: 12)),
                              ),
                              DataCell(
                                Text(
                                    data['SafetyStock']?.toString() ??
                                        'No data',
                                    style: TextStyle(fontSize: 12)),
                              ),
                              DataCell(
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () =>
                                      _showImportExportDialog(context, data),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
