import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../Providers/PaintProvider.dart';
import '../models/Point.dart';
import '../models/HexColor.dart';
import 'RouterService.dart';
import 'GetItLocator.dart';
import 'SocketStream.dart';
import 'LocalStorageService.dart';

class SocketIOservice {
  Socket socket;
  SocketStream _socketStream = locator<SocketStream>();
  LocalStorageService _localStorage = locator<LocalStorageService>();
  Function(bool, int) onRoomCreated;
  void connectToServer() {
    try {
      socket = io('https://6f0d81afdc4a.ngrok.io', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });
      socket.on('connect', (data) async{
        print('Connected: ${socket.id}');
        String username = await _localStorage.getString('username');
        socket.emit('connected', username);
      });
      socket.on(
        "drawing",
            (data) {
          if (data != null) {
            _socketStream.addPoint(
              Point(
                offset: Offset(data["dx"].toDouble(), data["dy"].toDouble()),
                width: data["strokeWidth"].toDouble(),
                color: HexColor(
                  data["strokeColor"],
                ),
              ),
            );
          } else {
            _socketStream.addPoint(null);
          }
        },
      );

      socket.on("clearDrawing", (data) {
        _socketStream.clearDrawing();
      });

      socket.on("room created", (data) {
        bool success = data["success"] as bool;
        int roomId = data["roomId"] as int;
        if(success) {
          onRoomCreated(true, roomId);
        } else {
          onRoomCreated(false, null);
        }
      });
      socket.on("connect_error", (data) {
        print(data);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void sendPoints(Point point) {
    socket.emit('drawing', point.toJson());
  }

  void clearDrawing() {
    socket.emit("clearDrawing");
  }

  void createRoom({String roomName, int maxPlayers, int gameMode}) {
    socket.emit("create room",
        {"roomName": roomName, "maxPlayers": maxPlayers, "gameMode": gameMode});
  }
}
