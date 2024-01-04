import 'package:flutter/material.dart';
import 'package:sms_app/pages/scan_page.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              const Text("Test"),
              const Text('Body'),
              
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const ScanPage())
                  );
                },
                child: const Text("Tap on this"),
              ),
            ],
          )
        )
      )
    );
  }
}