import 'package:flutter/material.dart';
import 'services/LocalStorageService.dart';
import 'services/GetItLocator.dart';

class Start extends StatefulWidget {
  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> {

  LocalStorageService _localStorageService = locator<LocalStorageService>();
  Future checkUsernameIsSet() async{
    final username = await _localStorageService.getString('username');
    if(username == null) {
      Navigator.of(context).pushReplacementNamed('/introduction');
    }
    else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void initState() {
    checkUsernameIsSet();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}