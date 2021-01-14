import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share/share.dart';
import '../services/SocketIOService.dart';
import '../services/GetItLocator.dart';
import '../services/FlushbarHelper.dart';
import '../commons/custom_icons.dart';
import '../services/DynamicLinkService.dart';
class ShareRoomScreen extends StatefulWidget {
  final message;
  final roomId;
  ShareRoomScreen({Key key, this.message, this.roomId}) : super(key: key);
  @override
  _ShareRoomScreenState createState() => _ShareRoomScreenState();
}

class _ShareRoomScreenState extends State<ShareRoomScreen> {
  SocketIOservice _socketIOService = locator<SocketIOservice>();
  final DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAlert(widget.message);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.93,
              decoration: BoxDecoration(
                color: Color(0xff4f6ce4),
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: SvgPicture.asset('assets/images/blank_canvas.svg'),
                    ),
                  ),
                  Text(
                    'Copy and send Room ID to your friends',
                    style: TextStyle(color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(5.0),
                        ),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Text('${widget.roomId}', style: TextStyle(fontSize: 18),),
                              ),
                            ),
                            Icon(Icons.copy, color: Colors.red)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ButtonTheme(
                            height: 50,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(20.0),
                              ),
                              color: Color(0xfff6b643),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Enter Room',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Icon(CustomIcons.enter_room,
                                              color: Colors.white)
                                        ],
                                      ),
                              ),
                              onPressed: () {

                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ButtonTheme(
                            height: 50,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(20.0),
                              ),
                                color: Color(0xffef80ad),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Share room link',
                                      style:
                                      TextStyle(color: Colors.white),
                                    ),
                                    Icon(Icons.share,
                                        color: Colors.white)
                                  ],
                                ),
                              ),
                              onPressed: () async{
                                final String url = await _dynamicLinkService
                                    .createRoomLink(widget.roomId);
                                Share.share('Play a game with me. \n$url');
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showAlert(String message) {
    FlushbarAlert.showAlert(
        context: context, title: 'Success', message: message, seconds: 3);
  }
}
