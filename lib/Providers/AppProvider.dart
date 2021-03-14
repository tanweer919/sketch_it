import 'package:flutter/material.dart';
import '../models/User.dart';
class AppProvider extends ChangeNotifier {
  User _currentUser;
  AppProvider(this._currentUser);

  User get currentUser => _currentUser;

  void set currentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}