import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TampilkanDataScreen extends StatefulWidget {
  @override
  _TampilkanDataScreenState createState() => _TampilkanDataScreenState();
}

class _TampilkanDataScreenState extends State<TampilkanDataScreen> {
  List<dynamic> _dataList = [];

  @override
  void initState() {
    super.initState();
    _ambilData();
  }

  Future<void> _ambilData() async {
    final response = await http.get(Uri.parse('http://localhost:3000/data'));

    if (response.statusCode == 200) {
      final List<dynamic> fetchedData = json.decode(response.body);
      setState(() {
        _dataList = fetchedData;
      });
    } else {
      print("Gagal get data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _dataList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _dataList.length,
              itemBuilder: (context, index) {
                final item = _dataList[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ExpansionTile(
                    title: Text(item['title'] ?? 'Ngga ada judul'),
                    subtitle: Text(item['description'] ?? 'Ngg ada deskripsi'),
                    children: <Widget>[
                      item['imageUrl'] != null
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(
                                item['imageUrl'] ?? '',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Ngg ada gambar'),
                            ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
