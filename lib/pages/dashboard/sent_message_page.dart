import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../../components/app_bar_search_component.dart';

class SentMessagePage extends StatefulWidget {
  const SentMessagePage({super.key});

  @override
  State<SentMessagePage> createState() => _SentMessagePageState();
}

class _SentMessagePageState extends State<SentMessagePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<List<dynamic>> _fetchData = getAPI();

  Future<List<dynamic>> getAPI() async {
    final SharedPreferences prefs = await _prefs;
    
    var url = Uri.http(
      '192.168.137.1:8000', 
      '/api/text-message',
      {'id': prefs.getString('deviceToken')!.replaceAll('qr_', ''), 'type': 'sent' }
    );

    var response = await http.get(
      url, 
      headers: { 'Accept': 'application/json' },
    );

    if(response.statusCode == 200){
      var jsonList = convert.jsonDecode(response.body);
      return jsonList['data'];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarSearchComponent(title: 'Sent SMS',),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // _fetchData = getAPI();
          setState(() {
            _fetchData = getAPI();
          });
        }, 
        child: const Icon(Icons.refresh)
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> post = snapshot.data![index];

                return ListTile(
                  title: Text(post['content']),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}