import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/GetItLocator.dart';
import '../models/Chat.dart';
import '../commons/enums.dart';
import '../services/SocketIOService.dart';
import '../Providers/AppProvider.dart';
import '../widgets/ShareRoomModal.dart';
import '../models/User.dart';
import '../Providers/RoomProvider.dart';
import '../widgets/GameView.dart';
import '../models/Player.dart';

class GameScreen extends StatefulWidget {
  final String roomId;
  final bool roomCreated;
  final Map<String, dynamic> initialRoomData;
  GameScreen({Key key, this.roomId, this.roomCreated, this.initialRoomData})
      : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  RoomProvider _roomProvider;
  SocketIOService _socketIOService = locator<SocketIOService>();
  @override
  void initState() {
    //Create provider for the created room with the initial data received from the server
    _roomProvider = locator<RoomProvider>(param1: {
      "roomId": widget.roomId,
      "players": widget.initialRoomData["players"]
          .map<Player>(
            (player) => Player(
              user: User(
                username: player["user"]["username"],
                profilePicUrl: player["user"]["profilePicUrl"]
              ),
              score: player["score"],
            ),
          )
          .toList(),
      "messages": widget.initialRoomData["messages"]
          .map<Chat>((message) => Chat.fromJson(message))
          .toList(),
      "sketcher": Player(
        user: User(
          username: widget.initialRoomData["sketcher"]["user"]["username"],
          profilePicUrl: widget.initialRoomData["sketcher"]["user"]["profilePicUrl"]
        ),
        score: widget.initialRoomData["sketcher"]["score"],
      ),
      "admin": User(
        username: widget.initialRoomData["admin"]["username"],
        profilePicUrl: widget.initialRoomData["admin"]["profilePicUrl"]
      ),
      "status": widget.initialRoomData["status"],
      "gameStatus": GameStatus.values[widget.initialRoomData["gameStatus"]]
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.roomCreated == true) {
        showWelcomeDialog();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppProvider appProvider = Provider.of<AppProvider>(context);
    return ChangeNotifierProvider(
        create: (context) => _roomProvider,
        child: Consumer<RoomProvider>(
          builder: (context, model, child) => WillPopScope(
            onWillPop: () async {
              final value = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text('Are you sure you want to leave the game?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: Text('Yes, leave'),
                          onPressed: () {
                            //Cancel all subscriptions to the different streams
                            model.cancelStreamSubsciptions();
                            //Inform server that the player is leaving
                            _socketIOService.leaveRoom(
                                roomId: widget.roomId,
                                username: appProvider.currentUser.username);
                            Navigator.of(context).pushReplacementNamed('/home');
                          },
                        ),
                      ],
                    );
                  });

              return value == true;
            },
            child: GameView(),
          ),
        ));
  }

  void showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        backgroundColor: Colors.white,
        child: ShareRoomModal(roomId: widget.roomId, roomCreated: true),
      ),
    );
  }
}
