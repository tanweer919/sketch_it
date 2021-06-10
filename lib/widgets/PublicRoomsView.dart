import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/PublicRoom.dart';
import '../services/RoomService.dart';
import '../services/GetItLocator.dart';
import 'package:dotted_border/dotted_border.dart';
import '../commons/CustomElevatedButton.dart';
import '../services/SocketStream.dart';
import '../commons/enums.dart';
import '../services/FlushbarHelper.dart';
import '../services/SocketIOService.dart';
import '../Providers/AppProvider.dart';

class PublicRoomView extends StatefulWidget {
  @override
  State<PublicRoomView> createState() => _PublicRoomViewState();
}

class _PublicRoomViewState extends State<PublicRoomView> {
  Future<List<PublicRoom>> _fetchedPublicRooms;
  RoomService _roomService = locator<RoomService>();
  SocketStream _socketStream = locator<SocketStream>();
  SocketIOService _socketIOService = locator<SocketIOService>();
  StreamSubscription _gameStreamSubscription;
  void initState() {
    super.initState();
    AppProvider _initialState =
        Provider.of<AppProvider>(context, listen: false);
    _initialState.loadPublicRooms();
    _gameStreamSubscription = _socketStream.gameStream.listen(
      (data) {
        if (data["action"] == GameAction.JoinGame) {
          print(data);
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Rooms',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            Consumer<AppProvider>(
              builder: (context, model, child) {
                List<PublicRoom> rooms = model.publicRooms;
                return rooms != null
                    ? roomsListView(rooms: rooms, model: model)
                    : Center(
                        child: CircularProgressIndicator(),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget roomsListView({List<PublicRoom> rooms, AppProvider model}) {
    return ListView.builder(
      itemCount: rooms.length,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        PublicRoom room = rooms[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: Radius.circular(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              room.roomId,
                              style: TextStyle(fontSize: 16),
                            ),
                            Text('Created by ${room.adminUsername}')
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            '${room.noOfPlayers} / ${room.maxPlayers} players',
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
//                              child: LargeButton(
//                                child: Text(
//                                  'Join this room',
//                                  style: TextStyle(
//                                      color: Colors.white, fontSize: 13),
//                                ),
//                                buttonPressed: false,
//                                width: 120,
//                                onTap: () {},
//                              ),
                            child: CustomElevatedButton(
                              inProgress: model.isRoomJoiningInProgress[index],
                              height: 30,
                              minWidth: 80,
                              label: 'Join this room',
                              onPressed: () {
                                onRoomJoinPressed(
                                    model: model,
                                    roomId: room.roomId,
                                    index: index);
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future onRoomJoinPressed(
      {AppProvider model, String roomId, int index}) async {
    model.modifyRoomProgress(index: index, value: true);
    final result = await _roomService.checkRoom(roomId: roomId);
    model.modifyRoomProgress(index: index, value: false);
    if (result["success"]) {
      _socketIOService.joinRoom(
          roomId: roomId,
          username: model.currentUser.username,
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
