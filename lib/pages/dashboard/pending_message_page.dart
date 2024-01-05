import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:sms_app/components/app_bar_search_component.dart';
import 'package:sms_app/utils.dart';
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
  late Timer _timer;
  double turns = 0.0;
  int seconds = 0;


  // SECTION API
  // NOTE GETAPI
  Future<List<dynamic>> getAPI() async {
    final SharedPreferences prefs = await _prefs;
    coloredPrint(text: 'getAPI will fetch');

    var response = await http.get(
      Uri.parse('${prefs.getString('url')}/api/text-message?type=pending&id=${prefs.getString('deviceToken')!.replaceAll('qr_', '')}'),
      headers: { 'Accept': 'application/json' },
    );

    if(response.statusCode == 200){
      var jsonList = convert.jsonDecode(response.body);
      if(jsonList['data'].length > 0) {
        coloredPrint(text: 'getAPI success returned 200 [data:${jsonList['data'].length}]', color: 'success');

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
    coloredPrint(text: 'postAPI will send SMS');
    final SharedPreferences prefs = await _prefs;

    // NOTE ERROR cannot send sms
    if(await uSendMessage('0$mobile', content) == false) {
      coloredPrint(text: 'SMS send error will not postAPI()', color: 'error');
    }
    // NOTE message sent
    else {
      coloredPrint(text: 'SMS Success! Will update postAPI to server');

      var res = await http.put(
        Uri.parse('${prefs.getString('url')}/api/text-message/$id'), 
        headers: { 'Accept': 'application/json' },
        body: {'device_id': prefs.getString('deviceToken')!.replaceAll('qr_', '') }
      );

      if(res.statusCode == 200) {
        coloredPrint(text: 'postAPI success returned 200 id:$id', color: 'success');

        coloredPrint(text: 'Will wait after 5 seconds');

        Timer(const Duration(seconds: 5), () {
          if(mounted) {
            coloredPrint(text: "Waiting done");
            setState(() {
              coloredPrint(text: 'getAPI is called', color: 'success');
              _fetchData = getAPI();
            });
          }
        });
      }
    }
  }


  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) { 
      seconds = timer.tick;
      if(seconds % 60 == 0) {
        coloredPrint(text: 'Timer executed minute:${timer.tick}');
        setState(() {
          _fetchData = getAPI();
        });
      }
    });

    
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
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
            if(snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Waiting for any sms.')
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> message = snapshot.data![index];

                if(index == 0) {
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
                    title: Text('0${message['user_register']['mobile']} - ${message['user_register']['last_name']}, ${message['user_register']['first_name']} ${message['user_register']['mid_name'] ?? ''} ${message['user_register']['ext_name'] ?? ''}'),
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