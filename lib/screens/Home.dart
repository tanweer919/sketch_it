import 'dart:async';
import 'dart:ui';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../services/GetItLocator.dart';
import '../services/SocketIOService.dart';
import '../services/RoomService.dart';
import '../services/FlushbarHelper.dart';
import '../Providers/AppProvider.dart';
import '../commons/LargeYellowButton.dart';
import '../widgets/PublicRoomsView.dart';
import '../services/SocketStream.dart';
import '../commons/enums.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  SocketIOService _socketIOService = locator<SocketIOService>();
  RoomService _roomService = locator<RoomService>();
  TextEditingController _roomIdFieldController = TextEditingController();
  bool _roomJoiningInProgress = false;
  bool _roomJoinButtonPressed = false;
  bool _createRoomButtonPressed = false;
  GlobalKey key = GlobalKey();
  FocusNode _textFieldFocus = FocusNode();
  bool _textFieldHasFocus = false;
  SocketStream _socketStream = locator<SocketStream>();
  StreamSubscription _gameStreamSubscription;
  @override
  void initState() {
    super.initState();
    _textFieldFocus.addListener(() {
      if (_textFieldFocus.hasFocus) {
        setState(() {
          _textFieldHasFocus = true;
        });
      } else {
        setState(() {
          _textFieldHasFocus = false;
        });
      }
    });

    _gameStreamSubscription = _socketStream.gameStream.listen(
      (data) {
        if (data["action"] == GameAction.JoinGame) {
          Navigator.of(context).pushReplacementNamed('/join', arguments: {
            "roomId": data["data"]["roomId"],
            "initialRoomData": data["data"]["initialRoomData"]
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _gameStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppProvider _appProvider = Provider.of<AppProvider>(context);
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image:
                                AssetImage('assets/images/border_drawing.png'),
                            fit: BoxFit.fill,
                          ),
                          color: Colors.white),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.25,
                              child: SvgPicture.asset(
                                  'assets/images/blank_canvas.svg'),
                            ),
                          ),
                          Text(
                            'Enter Room ID to join',
                            style: TextStyle(fontSize: 16),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 8.0),
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: Radius.circular(5.0),
                              color: _textFieldHasFocus
                                  ? Color(0xff3366ff)
                                  : Colors.black,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(5.0),
                                ),
                                child: Container(
                                  child: TextField(
                                    focusNode: _textFieldFocus,
                                    controller: _roomIdFieldController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                        hintText: 'Room ID',
                                        contentPadding: EdgeInsets.all(8.0),
                                        fillColor: Colors.white,
                                        focusColor: Colors.white,
                                        border: new OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(5.0),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(5.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: Color(0xff3366ff),
                                          ),
                                        )),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_roomJoinButtonPressed)
                            SizedBox(
                              height: 16.0,
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LargeButton(
                                  inProgress: _roomJoiningInProgress,
                                  buttonPressed: _roomJoinButtonPressed,
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  isPrimaryColor: true,
                                  onTap: () async {
                                    await onRoomJoinPressed(
                                        appProvider: _appProvider);
                                  },
                                  child: Text(
                                    'Join Room',
                                    style: TextStyle(
                                        color: Color(0xfff5f5f5), fontSize: 18),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.23,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image:
                                AssetImage('assets/images/dotted_border.png'),
                            fit: BoxFit.fill,
                          ),
                          color: Colors.white),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Create Room and invite friends to join',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff8d8c8a),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              key: key,
                              children: [
                                LargeButton(
                                  child: Text(
                                    'Create Room',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  inProgress: false,
                                  buttonPressed: _createRoomButtonPressed,
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  isPrimaryColor: false,
                                  onTap: () {
                                    setState(() {
                                      _createRoomButtonPressed = true;
                                    });
                                    RenderBox box =
                                        key.currentContext.findRenderObject();
                                    Offset position =
                                        box.localToGlobal(Offset.zero);
                                    Offset modifiedPosition = Offset(
                                        position.dx +
                                            MediaQuery.of(context).size.width /
                                                2,
                                        position.dy);
                                    Timer(Duration(milliseconds: 50), () {
                                      setState(() {
                                        _createRoomButtonPressed = false;
                                      });
                                      Navigator.of(context).pushNamed(
                                        '/createroom',
                                        arguments: {"offset": modifiedPosition},
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    PublicRoomView(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future onRoomJoinPressed({AppProvider appProvider}) async {
    setState(() {
      _roomJoiningInProgress = true;
      _roomJoinButtonPressed = true;
    });
    Timer(Duration(milliseconds: 50), () {
      setState(() {
        _roomJoinButtonPressed = false;
      });
    });
    final result =
        await _roomService.checkRoom(roomId: _roomIdFieldController.text);
    setState(
      () {
        _roomJoiningInProgress = false;
      },
    );
    if (result["success"]) {
      _socketIOService.joinRoom(
          roomId: _roomIdFieldController.text,
          username: appProvider.currentUser.username,
          source: "roomId");
    } else {
      FlushbarAlert.showAlert(
          context: context,
          title: 'Error',
          message: result["message"],
          seconds: 3);
    }
  }
}
