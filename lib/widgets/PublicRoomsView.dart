import 'package:flutter/material.dart';
import '../models/PublicRoom.dart';
import '../services/RoomService.dart';
import '../services/GetItLocator.dart';

class PublicRoomView extends StatefulWidget {
  @override
  State<PublicRoomView> createState() => _PublicRoomViewState();
}

class _PublicRoomViewState extends State<PublicRoomView> {
  Future<List<PublicRoom>> _fetchedPublicRooms;
  RoomService _roomService = locator<RoomService>();

  void initState() {
    super.initState();
    setState(() {
      _fetchedPublicRooms = _roomService.fetchAllPublicRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        'Public Rooms',
        style: TextStyle(fontSize: 18),
      ),
      FutureBuilder(
          future: _fetchedPublicRooms,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    snapshot.error.toString(),
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }
              if (snapshot.hasData) {
                List<PublicRoom> rooms = snapshot.data;
                return roomsListView(rooms: rooms);
              }
            }
          })
    ]);
  }

  Widget roomsListView({List<PublicRoom> rooms}) {
    return ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Text(rooms[index].name),
          );
        });
  }
}
