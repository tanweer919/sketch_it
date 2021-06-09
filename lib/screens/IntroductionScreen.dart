import 'package:flare_flutter/asset_provider.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_cache.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import '../widgets/WaveClipPath.dart';
import '../widgets/SmallerWaveClipPath.dart';
import '../services/GetItLocator.dart';
import '../services/UserService.dart';
import '../services/FlushbarHelper.dart';
import '../services/LocalStorageService.dart';
import '../Providers/AppProvider.dart';
import '../models/User.dart';
import '../services/FirebaseAuthService.dart';
import '../services/SocketIOService.dart';

class IntroductionScreen extends StatefulWidget {
  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  String _animation = "draw_hexagon";
  Future<void> _warmupAnimations(AssetProvider assetProvider) async {
    await cachedActor(assetProvider);
  }

  final UserService _userService = locator<UserService>();
  final FirebaseAuthService _firebaseAuthService =
      locator<FirebaseAuthService>();
  final LocalStorageService _localStorage = locator<LocalStorageService>();
  final SocketIOService _socketIOService = locator<SocketIOService>();
  bool _loginInProgress = false;

  @override
  void initState() {
    final AssetProvider assetProvider =
        AssetFlare(bundle: rootBundle, name: 'assets/rive/draw.flr');
    _warmupAnimations(assetProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AppProvider appProvider = Provider.of<AppProvider>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
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
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: FlareActor(
                            "assets/rive/draw.flr",
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                            animation: _animation,
                            callback: (value) {},
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: ElevatedButton(
                                  onPressed: !_loginInProgress
                                      ? () async {
                                          setState(() {
                                            _loginInProgress = true;
                                          });
                                          final FirebaseAuth.User user =
                                              await _firebaseAuthService
                                                  .signInWithGoogle();
                                          final result =
                                              await _userService.checkUser(
                                                  firebaseToken: user.uid);
                                          final bool success =
                                              result['success'];
                                          if (success) {
                                            final bool registered =
                                                result['registered'];
                                            if (registered) {
                                              final String username =
                                                  result['username'];
                                              _localStorage.setString(
                                                  'username', username);
                                              appProvider.currentUser = User(
                                                  username: username,
                                                  email: user.email,
                                                  profilePicUrl: user.photoURL);
                                              _socketIOService.connectToServer();
                                              Navigator.of(context)
                                                  .pushReplacementNamed(
                                                      '/home');
                                            } else {
                                              Navigator.of(context)
                                                  .pushReplacementNamed(
                                                '/username',
                                                arguments: {
                                                  "googleLoginUsed": true,
                                                  "firebaseToken": user.uid,
                                                  "email": user.email,
                                                  "profilePicUrl": user.photoURL
                                                },
                                              );
                                            }
                                          } else {
                                            FlushbarAlert.showAlert(
                                                context: context,
                                                title: 'Error',
                                                message: result["message"],
                                                seconds: 3);
                                          }
                                        }
                                      : () {},
                                  child: _loginInProgress
                                      ? CircularProgressIndicator(
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Color(0xfff5f5f5)),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                                color: Colors.white,
                                                height: 30,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Image.asset(
                                                      'assets/images/google_logo.png'),
                                                )),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Sign in with Google',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )
                                          ],
                                        ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      Color(0xff4285f4),
                                    ),
                                    padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed(
                              '/username',
                              arguments: {
                                "googleLoginUsed": false,
                                "firebaseToken": null,
                                "email": null,
                                "profilePicUrl": null
                              },
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).primaryColor),
                          ),
                          child: Text(
                            'Continue as guest',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
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
