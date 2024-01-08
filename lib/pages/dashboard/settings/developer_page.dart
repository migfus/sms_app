import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperPage extends StatelessWidget {
  const DeveloperPage({super.key});

  _launchURL(String value) async {
    final Uri url = Uri.parse(value);
    if(await canLaunchUrl(url)) {
      await launchUrl(url);
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.grey[50],
        title: const Text('About this application'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // NOTE Remove this Device
            const ListTile(
              leading: Icon(Icons.extension),
              title: Text("Version 0.0.2 - Vulnerability Fix Update"),
            ),

            // NOTE Developer
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text("Schwarzenegger R. Belonio"),
              onTap: () => _launchURL('https://github.com/migfus'),
            ),
          ],
        ),
      ),
    );
  }
}

