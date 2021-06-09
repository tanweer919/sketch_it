import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../services/SocketIOService.dart';
import '../services/GetItLocator.dart';
import '../services/FlushbarHelper.dart';
import '../Providers/AppProvider.dart';
import '../commons/SelectOption.dart';

class CreateRoomScreen extends StatefulWidget {
  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  SocketIOService _socketIOService = locator<SocketIOService>();
  TextEditingController _roomNameController = TextEditingController();
  double maxp = 4;
  int _selectedMode = 0;
  int _selectedVisiblity = 0;
  bool _inProgress = false;

  @override
  void initState() {
    _socketIOService.onRoomCreated = _onRoomCreated;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AppProvider appProvider = Provider.of<AppProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
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
                    'Choose a name for your room',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
                      child: TextField(
                        controller: _roomNameController,
                        decoration: InputDecoration(
                          hintText: 'Room Name',
                          contentPadding: EdgeInsets.all(8.0),
                          fillColor: Colors.white,
                          focusColor: Colors.white,
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(5.0),
                            ),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Select maximum number of players:',
                          style: TextStyle(color: Colors.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2)),
                            ),
                            child: Center(child: Text('${maxp.toInt()}')),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        valueIndicatorColor: Colors.blue,
                        activeTickMarkColor: Colors.white,
                        tickMarkShape:
                            RoundSliderTickMarkShape(tickMarkRadius: 3),
                        inactiveTickMarkColor: Colors.white,
                        inactiveTrackColor: Colors.red, // Custom Gray Color
                        activeTrackColor: Color(0xff67C9A2),
                        thumbColor: Color(0xfff6b643),
                        overlayColor:
                            Color(0x29EB1555), // Custom Thumb overlay Color
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 12.0),
                        overlayShape:
                            RoundSliderOverlayShape(overlayRadius: 20.0),
                      ),
                      child: Slider(
                        onChanged: (double value) {
                          setState(() {
                            maxp = value;
                          });
                        },
                        value: maxp,
                        min: 4,
                        max: 16,
                        divisions: 6,
                        label: '${maxp.toInt()}',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Select Visiblity of the room',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SelectOption(
                        label: 'Private',
                        backgroundImagePath: 'assets/images/private_room.svg',
                        isSelected: _selectedVisiblity == 0,
                        onTap: () {
                          setState(() {
                            _selectedVisiblity = 0;
                          });
                        },
                      ),
                      SelectOption(
                        label: 'Public',
                        backgroundImagePath: 'assets/images/public_room.svg',
                        isSelected: _selectedVisiblity == 1,
                        onTap: () {
                          setState(() {
                            _selectedVisiblity = 1;
                          });
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Select Playing Mode',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SelectOption(
                        label: 'Individual\nMode',
                        backgroundImagePath: 'assets/images/create_room.svg',
                        isSelected: _selectedMode == 0,
                        onTap: () {
                          setState(() {
                            _selectedMode = 0;
                          });
                        },
                      ),
                      SelectOption(
                        label: 'Coming\nSoon',
                        backgroundImagePath: 'assets/images/team.svg',
                        isSelected: _selectedMode == 1,
                        onTap: () {},
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 24.0),
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
                                child: _inProgress
                                    ? CircularProgressIndicator(
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                          Color(0xfff5f5f5),
                                        ),
                                      )
                                    : Text(
                                        'Create Room',
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ),
                              onPressed: _inProgress
                                  ? () {}
                                  : () {
                                      if (_roomNameController.text != '') {
                                        setState(() {
                                          _inProgress = true;
                                        });
                                        _socketIOService.createRoom(
                                            roomName: _roomNameController.text,
                                            maxPlayers: maxp.toInt(),
                                            gameMode: _selectedMode,
                                            visiblity: _selectedVisiblity,
                                            username: appProvider
                                                .currentUser.username);
                                      } else {
                                        FlushbarAlert.showAlert(
                                            context: context,
                                            title: 'Error',
                                            message:
                                                'Room name cannot be blank',
                                            seconds: 3);
                                      }
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

  void _onRoomCreated(bool success, Map<String, dynamic> data) {
    print(data);
    if (success) {
      setState(() {
        _inProgress = false;
      });
      Navigator.of(context).pushReplacementNamed('/join', arguments: {
        "roomId": data["roomId"],
        "roomCreated": true,
        "initialRoomData": data["initialRoomData"]
      });
    } else {
      print("Error in room creation");
    }
  }
}
