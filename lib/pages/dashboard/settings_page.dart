import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:sms_app/pages/dashboard/settings/developer_page.dart';
import 'package:sms_app/pages/intro_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> _setDeviceToken() async {
    final SharedPreferences prefs = await _prefs;

    var res = await http.delete(
      Uri.parse('${prefs.getString('url')}/api/device/${prefs.getString('deviceToken')!.replaceAll('qr_', '')}'),
      headers: { 'Accept': 'application/json' },
    );

    if(res.statusCode == 200) {
      prefs.setString('deviceToken', "");
    }
  }

  Future<String> getStringValue(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(key) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.grey[50],
        title: const Text('Settings'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                _setDeviceToken();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IntroPage())
                );
              },
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // NOTE Remove this Device
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Remove this device"),
              onTap: () async {
                await _setDeviceToken();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IntroPage())
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.key),
              title: FutureBuilder(
                future: getStringValue('deviceToken'),
                builder: (context, snapshot) {
                  return Text('Token: ${snapshot.data ?? ''}');
                },
              )
            ),

            ListTile(
              leading: const Icon(Icons.link),
              title: FutureBuilder(
                future: getStringValue('url'),
                builder: (context, snapshot) {
                  return Text('Url: ${snapshot.data ?? ''}');
                },
              )
            ),

            // NOTE Developer
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About v0.0.1"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DeveloperPage())
                );
              },
            ),
          ],
        ),
      )
    );
  }
}