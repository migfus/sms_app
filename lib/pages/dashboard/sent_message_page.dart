import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:ohrm_sms/types/TextMessage.dart';
import 'package:ohrm_sms/utils.dart';
import 'dart:convert' as convert;
import 'package:timeago/timeago.dart' as timeago;

import '../../components/app_bar_search_component.dart';

class SentMessagePage extends StatefulWidget {
  const SentMessagePage({super.key});

  @override
  State<SentMessagePage> createState() => _SentMessagePageState();
}

class _SentMessagePageState extends State<SentMessagePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<List<TextMessage>> _fetchData = getAPI();

  Future<List<TextMessage>> getAPI() async {
    final SharedPreferences prefs = await _prefs;

    var res = await http.get(
      Uri.parse('${prefs.getString('url')}/api/text-message?type=sent&id=${prefs.getString('deviceToken')}'),
      headers: { 'Accept': 'application/json' },
    );

    if(res.statusCode == 200){
      coloredPrint(text: 'sent status 200');
      final rawJsonData = convert.jsonDecode(res.body);
      final List<dynamic> jsonData = rawJsonData['data'];
      final List<TextMessage> messages = jsonData.map((data) => TextMessage.fromJson(data)).toList();
      coloredPrint(text: 'sent status past json to messages');
      return messages;
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
                TextMessage message = snapshot.data![index];

                return ListTile(
                  title: Text('0${message.userRegister.mobile} - ${convertFullName(last: message.userRegister.lastName, first: message.userRegister.firstName, mid: message.userRegister.midName, ext: message.userRegister.extName)}'),
                  subtitle: Text(message.content),
                  trailing: Text(
                    timeago.format(DateTime.parse(message.readAt ?? '').add(const Duration(hours: 8)), locale: 'en_short')
                  ),
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