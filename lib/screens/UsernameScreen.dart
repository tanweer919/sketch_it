import 'package:flare_flutter/asset_provider.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_cache.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/WaveClipPath.dart';
import '../widgets/SmallerWaveClipPath.dart';
import '../services/GetItLocator.dart';
import '../services/UserService.dart';
import '../services/FlushbarHelper.dart';
import '../services/LocalStorageService.dart';
import '../Providers/AppProvider.dart';
import '../models/User.dart';
import '../services/SocketIOService.dart';

class UsernameScreen extends StatefulWidget {
  final bool googleLoginUsed;
  final String firebaseToken, email, profilePicUrl;
  UsernameScreen(
      {Key key,
      this.googleLoginUsed,
      this.firebaseToken,
      this.email,
      this.profilePicUrl})
      : super(key: key);
  @override
  _UsernameScreenState createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  String _animation = "idle";
  Future<void> _warmupAnimations(AssetProvider assetProvider) async {
    await cachedActor(assetProvider);
  }

  final UserService _userService = locator<UserService>();
  final LocalStorageService _localStorage = locator<LocalStorageService>();
  final SocketIOService _socketIOService = locator<SocketIOService>();

  bool _checkInProgress = false;
  bool _registerInProgress = false;
  bool usernameAvailable;
  TextEditingController _usernameFieldController = TextEditingController();

  @override
  void initState() {
    final AssetProvider assetProvider =
        AssetFlare(bundle: rootBundle, name: 'assets/rive/Teddy.flr');
    _warmupAnimations(assetProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AppProvider _appProvider = Provider.of<AppProvider>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xff5D8E9B),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    ClipPath(
                      clipper: WaveClipPath(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.35,
                        color: Color(0xff4abef8),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: ClipPath(
                        clipper: SmallerWaveClipPath(),
                        child: Container(
                          color: Color(0xfff17e3a),
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width * 0.75,
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Welcome to \n Just Sketch',
                            style: TextStyle(
                                fontSize: 35,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: FlareActor(
                            "assets/rive/Teddy.flr",
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                            animation: _animation,
                            callback: (value) {},
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 16.0, top: 16.0),
                                    child: TextField(
                                      controller: _usernameFieldController,
                                      decoration: InputDecoration(
                                          hintText: 'Choose a username',
                                          labelText: 'Username',
                                          suffixIcon: usernameAvailable !=
                                                      null &&
                                                  usernameAvailable != ''
                                              ? UnconstrainedBox(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0),
                                                    child: _checkInProgress
                                                        ? Container(
                                                            height: 15,
                                                            width: 15,
                                                            child: Center(
                                                                child:
                                                                    CircularProgressIndicator(
                                                              strokeWidth: 2.0,
                                                            )),
                                                          )
                                                        : usernameAvailable
                                                            ? CircleAvatar(
                                                                maxRadius: 10,
                                                                backgroundColor:
                                                                    Color(
                                                                        0xff4ca746),
                                                                child: Icon(
                                                                  Icons.check,
                                                                  size: 13,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              )
                                                            : CircleAvatar(
                                                                maxRadius: 10,
                                                                backgroundColor:
                                                                    Colors.red,
                                                                child: Icon(
                                                                  Icons.clear,
                                                                  size: 13,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                  ),
                                                )
                                              : Container(
                                                  width: 0,
                                                )),
                                      onChanged: (value) async {
                                        if (value != '') {
                                          setState(() {
                                            _animation = "test";
                                            _checkInProgress = true;
                                          });
                                          final userRepsonse =
                                              await _userService.checkUsername(
                                                  username: value);

                                          if (userRepsonse["available"]) {
                                            setState(() {
                                              usernameAvailable = true;
                                            });
                                          } else {
                                            setState(() {
                                              usernameAvailable = false;
                                            });
                                          }
                                          setState(() {
                                            _checkInProgress = false;
                                          });
                                        } else {
                                          setState(() {
                                            _animation = "idle";
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16.0,
                                      right: 16.0,
                                      bottom: 8.0,
                                    ),
                                    child: Container(
                                      height: 20,
                                      child: usernameAvailable == false
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Username is already taken.',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: ButtonTheme(
                                            height: 50,
                                            child: RaisedButton(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        30.0),
                                              ),
                                              color: Color(0xfff6b643),
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: _registerInProgress
                                                      ? CircularProgressIndicator(
                                                          valueColor:
                                                              new AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.black),
                                                        )
                                                      : Text('Continue')),
                                              onPressed: _registerInProgress
                                                  ? () {}
                                                  : () async {
                                                      final username =
                                                          _usernameFieldController
                                                              .text;
                                                      if (username != '' &&
                                                          usernameAvailable) {
                                                        setState(() {
                                                          _registerInProgress =
                                                              true;
                                                        });
                                                        final result = await _userService.createUser(
                                                            username: username,
                                                            firebaseToken: widget
                                                                    .googleLoginUsed
                                                                ? widget
                                                                    .firebaseToken
                                                                : null,
                                                            email: widget
                                                                    .googleLoginUsed
                                                                ? widget.email
                                                                : null,
                                                            profilePicUrl: widget
                                                                    .googleLoginUsed
                                                                ? widget
                                                                    .profilePicUrl
                                                                : null);
                                                        setState(() {
                                                          _registerInProgress =
                                                              false;
                                                        });
                                                        if (result["success"]) {
                                                          _localStorage
                                                              .setString(
                                                                  'username',
                                                                  username);
                                                          _appProvider.currentUser = User(
                                                              username:
                                                                  username,
                                                              email: widget
                                                                      .googleLoginUsed
                                                                  ? widget.email
                                                                  : null,
                                                              profilePicUrl: widget
                                                                      .googleLoginUsed
                                                                  ? widget
                                                                      .profilePicUrl
                                                                  : null);
                                                          _socketIOService.connectToServer();
                                                          Navigator.of(context)
                                                              .pushReplacementNamed(
                                                                  '/home');
                                                        } else {
                                                          FlushbarAlert.showAlert(
                                                              context: context,
                                                              title: 'Error',
                                                              message: result[
                                                                  "message"],
                                                              seconds: 3);
                                                        }
                                                      }
                                                    },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
