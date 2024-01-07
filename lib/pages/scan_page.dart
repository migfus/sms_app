import 'dart:io';
import 'dart:math';
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_app/pages/dashboard_page.dart';
import 'package:vibration/vibration.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import '../utils.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScanPage();
}

class _ScanPage extends State<ScanPage> {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool confirmSent = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> _addDevice() async{
    final SharedPreferences prefs = await _prefs;
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    coloredPrint(text: 'postAPI will process');
    coloredPrint(text: 'testing generateID: ${generateID()}');
    
    var res = await http.post(
      Uri.parse('${prefs.getString('url') ?? 'https://id.migfus.net'}/api/device'),
      headers: { 'Accept': 'application/json' },
      body: {
        'id': generateID(),
        'name': androidInfo.brand,
        'platform': 'Android'
      }
    );

    if(res.statusCode == 200) {
      coloredPrint(text: 'Device has been added', color: 'success');
      var jsonList = convert.jsonDecode(res.body);
      return jsonList['data'];
    }

    return '';
  }

  String generateID({int len = 5}) {
    var r = Random();
    return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
  }

  


  void _onQRViewCreated(QRViewController controller) async {
    if(!confirmSent) {

      this.controller = controller;

      controller.scannedDataStream.listen((scanData) async {
        var jsonList = convert.jsonDecode(scanData.code!);

        controller!.pauseCamera();

        await _willVibrate();
        await _setDeviceToken(jsonList['link']);

        setState((){
          result = scanData;
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage())
        );
        confirmSent = true;
      });
    }
    
  }

  Future<void> _willVibrate() async {
    if (await Vibration.hasVibrator() != null) {
      await Vibration.vibrate(duration: 1000);
    }
  }

  Future<void> _setDeviceToken(String link) async {
    String devicID = await _addDevice();
    final prefs = await SharedPreferences.getInstance();
    
    prefs.setString('deviceToken', 'qr_$devicID');
    prefs.setString('url', link);
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    coloredPrint(text: '${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    Text('Device Token: ${result!.code}')
                  else
                    const Text('Scan a code'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ButtonTheme(
                          height: 1,
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller?.toggleFlash();
                            },
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                return Text('Flash: ${snapshot.data ?? false ? 'On' : 'Off'}');
                              },
                            )
                          ),
                        ),
                      ),
                      
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }
}