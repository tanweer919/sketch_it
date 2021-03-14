import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../Providers/PaintProvider.dart';
import '../models/Point.dart';
import '../models/HexColor.dart';
import 'RouterService.dart';
import 'GetItLocator.dart';
import 'SocketStream.dart';
import 'LocalStorageService.dart';
import '../models/Chat.dart';
import '../constants.dart';
import '../models/User.dart';
import '../commons/enums.dart';
import '../models/PictionaryWord.dart';

class SocketIOService {
  Socket socket;
  SocketStream _socketStream = locator<SocketStream>();
  LocalStorageService _localStorage = locator<LocalStorageService>();
  Function(bool, Map<String, dynamic>) onRoomCreated;
  Function(Map<String, dynamic>) onRoomJoinedUsingRoomId;
  Function(Map<String, dynamic>) onRoomJoinedUsingLink;

  void connectToServer() {
    try {
      socket = io(baseAddress, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });
      socket.on(ON_CONNECTION, (data) async {
        String username = await _localStorage.getString('username');
        socket.emit('connected', {"username": username});
      });
      socket.on(NEW_PLAYER, (username) {
        _socketStream.addPlayer(User(username: username));
      });
      socket.on(LEFT_ROOM, (data) {
        final username = data["username"];
        final roomId = data["roomId"];
        print(data);
        sendNewMessage(
          roomId: roomId,
          message: Chat(
              user: User(username: username),
              messageTypes: MessageTypes.LeftRoom,
              message: ''),
        );
        _socketStream.removePlayer(User(username: username));
      });
      socket.on(NEW_MESSAGE, (data) {
        _socketStream.addNewMessage(Chat.fromJson(data));
      });
      socket.on(
        DRAWING,
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

      socket.on(CLEAR_DRAWING, (data) {
        _socketStream.clearDrawing();
      });

      socket.on(JOINED_ROOM, (data) {
        print(data);
        if(data["source"] == "roomId") {
          onRoomJoinedUsingRoomId(data);
        } else if(data["source"] == "link") {
          onRoomJoinedUsingLink(data);
        }
      });

      socket.on(ROOM_CREATED, (data) {
        bool success = data["success"] as bool;
        if (success) {
          onRoomCreated(true, data);
        } else {
          onRoomCreated(false, null);
        }
      });

      socket.on(NEW_STATUS, (data) {
        _socketStream.newStatus(data["status"]);
      });

      socket.on(GAME_STARTED, (data) {
        print("game started");
        _socketStream.changeGameStatus(GameStatus.Started);
      },);
      socket.on(YOUR_TURN, (data) {
        List<PictionaryWord> pictionaryWords = [];
        final parsedData = data as List;
        for(int i = 0; i  < parsedData.length; i++) {
          pictionaryWords.add(PictionaryWord.fromJson(parsedData[i]));
        }
        _socketStream.selectWord(pictionaryWords);
      });

      socket.on(START_DRAWING, (data) {
        _socketStream.startDrawing();
      });

      socket.on(CONNECT_ERROR, (data) {
        print(data);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void sendPoints({String roomId, Point point}) {
    socket.emit(DRAWING, {"roomId": roomId, "point": point?.toJson()});
  }

  void sendNewMessage({String roomId, Chat message}) {
    socket.emit(NEW_MESSAGE, {"roomId": roomId, "message": message});
  }

  void clearDrawing({String roomId}) {
    socket.emit(CLEAR_DRAWING, {"roomId": roomId});
  }

  void createRoom(
      {String roomName, int maxPlayers, int gameMode, String username}) {
    socket.emit(
      CREATE_ROOM,
      {
        "roomName": roomName,
        "maxPlayers": maxPlayers,
        "gameMode": gameMode,
        "admin": username
      },
    );
  }

  void joinRoom({String roomId, String username, String source}) {
    socket.emit(JOIN_ROOM, {"roomId": roomId, "username": username, "source": source});
    sendNewMessage(
      roomId: roomId,
      message: Chat(
          user: User(username: username),
          messageTypes: MessageTypes.JoinedRoom,
          message: ''),
    );
  }

  void leaveRoom({String roomId, String username}) {
    socket.emit(LEAVE_ROOM, {"roomId": roomId, "username": username});
  }

  void startGame({String roomId, String username}) {
    socket.emit(START_GAME, {"roomId": roomId, "username": username});
  }

  void wordSelected({String roomId, String word}) {
    socket.emit(WORD_SELECTED, {"roomId": roomId, "selectedWord": word});
  }
}
