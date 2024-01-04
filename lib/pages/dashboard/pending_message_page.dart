import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:background_sms/background_sms.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:sms_app/components/app_bar_search_component.dart';
import 'package:timeago/timeago.dart' as timeago;


class PendingMessagePage extends StatefulWidget {
  const PendingMessagePage({super.key});

  @override
  State<PendingMessagePage> createState() => PendingMessagePageState();
}

class PendingMessagePageState extends State<PendingMessagePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<List<dynamic>> _fetchData = getAPI();
  late Timer timer;
  double turns = 0.0;
  int seconds = 0;


  // SECTION API
  // NOTE GETAPI
  Future<List<dynamic>> getAPI() async {
    final SharedPreferences prefs = await _prefs;
    printColored(text: 'getAPI will fetch');

    var response = await http.get(
      Uri.parse('http://192.168.137.1:8000/api/text-message?type=pending&id=${prefs.getString('deviceToken')!.replaceAll('qr_', '')}'),
      headers: { 'Accept': 'application/json' },
    );

    if(response.statusCode == 200){
      var jsonList = convert.jsonDecode(response.body);
      if(jsonList['data'].length > 0) {
        printColored(text: 'getAPI success returned 200 [data:${jsonList['data'].length}]', color: 'success');

        postAPI(
          id: jsonList['data'][0]['id'].toString(), 
          mobile: jsonList['data'][0]['user_register']['mobile'], 
          content: jsonList['data'][0]['content']
        );
        return jsonList['data'];
      }
    }
    return [];
  }

  // NOTE POSTAPI
  void postAPI({ required String id, required String mobile, required String content}) async {
    printColored(text: 'postAPI will send SMS');

    if(await _isPermissionGranted()) {
      if(await _sendMessage('0$mobile', content, simSlot: 1)) {

        printColored(text: 'SMS Success will update postAPI to server');
        final SharedPreferences prefs = await _prefs;

        var res = await http.put(
          Uri.parse('http://192.168.137.1:8000/api/text-message/$id'), 
          headers: { 'Accept': 'application/json' },
          body: {'device_id': prefs.getString('deviceToken')!.replaceAll('qr_', '') }
        );

        if(res.statusCode == 200) {
          printColored(text: 'postAPI success returned 200 id:$id', color: 'success');

          printColored(text: 'Will wait after 5 seconds');

          Timer(const Duration(seconds: 5), () {
            printColored(text: "Waiting done");
            setState(() {
              printColored(text: 'getAPI is called', color: 'success');
              _fetchData = getAPI();
            });
          });
        }

      }
      else {
        printColored(text: 'SMS send error will not postAPI()', color: 'error');
      }
    }
    else {
      await _getPermission();
    }
  }

  _getPermission() async => await [ Permission.sms,].request();

  Future<bool> _isPermissionGranted() async => await Permission.sms.status.isGranted;

  Future<bool> _sendMessage(String phoneNumber, String message, {int? simSlot}) async {
      var result = await BackgroundSms.sendMessage(
        phoneNumber: 
        phoneNumber, 
        message: message, 
        simSlot: simSlot
      );
      if (result == SmsStatus.sent) {
        printColored(text: "SMS Sent");
        return true;
      } 
      return false;
  }

  // SECTION FUNC
  void printColored({required String text, String color = 'white'}) {
    switch(color) {
      case 'danger':
        print('\x1B[31m$text\x1B[0m');
        break;
      case 'warning':
        print('\x1B[33m$text\x1B[0m');
        break;
      case 'success':
        print('\x1B[32m$text\x1b[0m');
      default: // info [white]
        print('\x1B[37m$text\x1B[0m');
    }
    
  }

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 1), (timer) { 
      seconds = timer.tick;
      if(seconds % 60 == 0) {
        printColored(text: 'Timer executed minute:${timer.tick}');
        setState(() {
          _fetchData = getAPI();
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarSearchComponent(title: 'Pending SMS',),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
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
                Map<String, dynamic> message = snapshot.data![index];

                if(index == 0) {
                  // printColored('ListView will display index[$index]');
                  // postAPI(
                  //   id: message['id'].toString(), 
                  //   mobile: message['user_register']['mobile'], 
                  //   content: message['content']
                  // );

                  return ListTile(
                    title: Text('0${message['user_register']['mobile']}'),
                    subtitle: Text(message['content']),
                    trailing: const SizedBox(
                      width: 10, height: 10,
                      child: CircularProgressIndicator()
                    )
                  );
                }
                else {
                  return ListTile(
                    title: Text('0${message['user_register']['mobile']}'),
                    subtitle: Text(message['content']),
                    trailing: Text(timeago.format(DateTime.parse(message['created_at']), locale: 'en_short'))
                  );
                }

                
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