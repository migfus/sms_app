import 'package:flutter/material.dart';

class IntroStore extends ChangeNotifier {
  bool _isNew = true;
  bool get isNew => _isNew;

  void noLongerNew() {
    _isNew = false;
    notifyListeners();
  }
}