import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DisplayDataScreen extends StatefulWidget {
  @override
  _DisplayDataScreenState createState() => _DisplayDataScreenState();
}

class _DisplayDataScreenState extends State<DisplayDataScreen> {
  List<dynamic> _dataList = []; // list untuk menyimpan data yang diambil

  @override
  void initState() {
    super.initState();
    _fetchData(); // panggil fungsi untuk mengambil data saat widget diinisialisasi
  }

  // fungsi untuk mengambil data dari server
  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse('http://localhost:3000/data'));

    if (response.statusCode == 200) {
      final List<dynamic> fetchedData = json.decode(response.body);
      setState(() {
        _dataList = fetchedData; // simpan data yang diambil
      });
    } else {
      print("Gagal mengambil data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tampilkan Data dari Server'),
      ),
      body: _dataList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _dataList.length,
              itemBuilder: (context, index) {
                final item = _dataList[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ExpansionTile(
                    title: Text(item['title'] ??
                        'No title available'), // fallback for null title
                    subtitle: Text(item['description'] ??
                        'No description available'), // fallback for null description
                    children: <Widget>[
                      item['imageUrl'] != null
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(
                                item['imageUrl'] ??
                                    '', // provide an empty string if imageUrl is null
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('No image available'),
                            ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
