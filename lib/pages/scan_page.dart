import 'dart:io';
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ohrm_sms/pages/dashboard_page.dart';
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
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      var jsonList = convert.jsonDecode(scanData.code!);
      controller.pauseCamera();

      await vibrateDevice();
      await setPrefsData(link: jsonList['link'], id: jsonList['id']);
      await postAPI();

      setState((){
        result = scanData;
      });

      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const DashboardPage())
      );
    });
    
    
  }

  

  Future<void> setPrefsData({required String link, required String id}) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('url', link);
    prefs.setString('deviceToken', id);
  }

  Future<void> postAPI() async{
    final SharedPreferences prefs = await _prefs;
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final String deviceToken = prefs.getString('deviceToken') ?? '';
    final String url = prefs.getString('url') ?? '';

    coloredPrint(text: 'postAPI will process');
    coloredPrint(text: 'testing for ID: $deviceToken');
    
    var res =   await http.put(
      Uri.parse('$url/api/device/$deviceToken'),
      headers: { 'Accept': 'application/json' },
      body: {
        'id': deviceToken,
        'name': androidInfo.brand,
        'platform': 'Android'
      }
    );

    if(res.statusCode == 200) {
      coloredPrint(text: res.body, color: 'success');
      coloredPrint(text: 'Device has been added', color: 'success');
    }
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