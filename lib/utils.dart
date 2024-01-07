import 'package:flutter/material.dart';
import 'package:background_sms/background_sms.dart';
import 'package:permission_handler/permission_handler.dart';


void coloredPrint({required String text, String color = 'white'}) {
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

void snackBarPopup(String content, BuildContext context) {
  final snackBar = SnackBar(
    content: Text(content), 
    duration: const Duration(seconds: 2)
  );

  ScaffoldMessenger.of(context).showMaterialBanner(snackBar as MaterialBanner);
}

// NOTE SMS

Future<bool> _isPermissionGrantedForSMS() async => await Permission.sms.status.isGranted;
_getPermissionForSms() async => await [ Permission.sms,].request();

Future<bool> uSendMessage(String phoneNumber, String message) async {
  if(await _isPermissionGrantedForSMS()) {
    bool? supportedCustomSim = await BackgroundSms.isSupportCustomSim;
    if(supportedCustomSim!) {
      var result = await BackgroundSms.sendMessage(phoneNumber: phoneNumber, message: message, simSlot: 1);
      if (result == SmsStatus.sent) {
        coloredPrint(text: "SMS Sent in [multi-Sim device] data: [$phoneNumber][$message]", color: 'success');
        return true;
      } 
      return false;
    }
    else {
      var result = await BackgroundSms.sendMessage(phoneNumber: phoneNumber, message: message);
      if (result == SmsStatus.sent) {
        coloredPrint(text: "SMS Sent in [single-Sim device] data: [$phoneNumber][$message]", color: 'success');
        return true;
      } 
      return false;
    }

    
  }
  else {
    coloredPrint(text: 'will ask for SMS permission');
    await _getPermissionForSms();
    coloredPrint(text: 'SMS permission granted', color: 'success');
    // call again if no permission;
    uSendMessage(phoneNumber, message);
  }
  
  return false;
}


// NOTE CONVERTION
String convertFullName({required String last, required String first, String? mid, String? ext}) {
  if(mid != null && ext != null) {
    return '$last, $first $mid. $ext.';
  }
  else if(mid != null) {
    return '$last, $first $mid.';
  }

  return '$last, $first';
}