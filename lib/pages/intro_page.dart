import 'package:flutter/material.dart';
import 'package:sms_app/pages/scan_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String _url = 'https://id.migfus.net';

  void _proceed() async {
    final SharedPreferences prefs = await _prefs;

    prefs.setString('url', _url);
    
  }

  void _initInput() async {
    final SharedPreferences prefs = await _prefs;
    _url = prefs.getString('url') ?? 'https://id.migfus.net';
  }

  @override
  void initState() {
    super.initState();
    _initInput();
    coloredPrint(text: 'Init Input');
  }

  @override
  Widget build(BuildContext context) {
  
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text("Welcome to Buggy AF OHRM SMS"),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Please enter the proper url target (ex: https://id.migfus.net)'),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: _url,
                  decoration: const InputDecoration(labelText: 'URL'),
                  validator: (value) {
                    return null;
                  },
                  onSaved: (value) => _url = value ?? '',
                ),
              ),
              
              
              ElevatedButton(
                onPressed: () async {
                  _proceed();

                  await Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const ScanPage())
                  );
                },
                child: const Text("Proceed"),
              ),
            ],
          )
        )
      )
    );
  }
}
