import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HistorySparePartsPage extends StatefulWidget {
  @override
  _HistorySparePartsPageState createState() => _HistorySparePartsPageState();
}

class _HistorySparePartsPageState extends State<HistorySparePartsPage> {
  Future<List<Map<String, dynamic>>> _LogData() async {
    final response = await http.get(Uri.parse('http://172.23.10.51:3005/Log'));
    if (response.statusCode == 200) {
      return json.decode(response.body).cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load data');
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return '';
    }
    try {
      DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    } catch (e) {
      return 'Invalid date';
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
                width: 400, // ปรับขนาดความกว้างตามต้องการ
                height: 400, // ปรับขนาดความสูงตามต้องการ
                fit: BoxFit.contain, // ปรับให้ภาพพอดีกับตัว Dialog
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
              'History Spare Part',
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
          future: _LogData(),
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
                            label: Text('Date',
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
                            label: Text('Remark',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Type',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('UserName',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ],
                        rows: snapshot.data!
                            .asMap()
                            .entries
                            .map<DataRow>((entry) {
                          final Map<String, dynamic> data = entry.value;

                          return DataRow(
                            cells: [
                              DataCell(Text(formatDate(data['Date']),
                                  style: TextStyle(fontSize: 12))),
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
                              DataCell(Text(
                                  data['Mat']?.toString() ?? 'No data',
                                  style: TextStyle(fontSize: 12))),
                              DataCell(Text(data['Name'] ?? 'No data',
                                  style: TextStyle(fontSize: 12))),
                              DataCell(
                                Text(data['Quantity']?.toString() ?? 'No data',
                                    style: TextStyle(fontSize: 12)),
                              ),
                              DataCell(Text(data['Remark'] ?? 'No data',
                                  style: TextStyle(fontSize: 12))),
                              DataCell(
                                Text(
                                  data['Type'] ?? 'No data',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: (data['Type'] == 'Import')
                                        ? Colors.green
                                        : (data['Type'] == 'Export')
                                            ? Colors.red
                                            : Colors.black,
                                  ),
                                ),
                              ),
                              DataCell(Text(data['UserName'] ?? 'No data',
                                  style: TextStyle(fontSize: 12))),
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
