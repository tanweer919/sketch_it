import 'package:flutter/material.dart';
import 'services/LocalStorageService.dart';
import 'services/GetItLocator.dart';
import 'services/SocketIOService.dart';

class Start extends StatefulWidget {
  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> {

  LocalStorageService _localStorageService = locator<LocalStorageService>();
  final SocketIOService _socketIOService = locator<SocketIOService>();
  Future checkUsernameIsSet() async{
    final username = await _localStorageService.getString('username');
    final String firstOpen = await _localStorageService.getString('firstOpen');
    if(firstOpen == null) {
      await _localStorageService.setString('firstOpen', 'no');
      Navigator.of(context).pushReplacementNamed('/introduction');
    }
    else {
      if(username == null) {
        Navigator.of(context).pushReplacementNamed(
          '/username',
          arguments: {
            "googleLoginUsed": false,
            "firebaseToken": null,
            "email": null,
            "profilePicUrl": null
          },
        );
      } else {
        _socketIOService.connectToServer();
        Navigator.of(context).pushReplacementNamed('/home');
      }
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