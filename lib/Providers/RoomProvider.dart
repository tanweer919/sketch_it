import 'dart:async';
import 'package:flutter/material.dart';
import '../services/SocketStream.dart';
import '../services/GetItLocator.dart';
import '../models/Chat.dart';
import '../models/User.dart';
import '../commons/enums.dart';
import '../models/Room.dart';
import '../models/Player.dart';

class RoomProvider extends ChangeNotifier {
  Room _room;
  String _status;
  Player _currentSketcher;
  StreamSubscription _messageStreamSubscription;
  StreamSubscription _playerStreamSubscription;
  StreamSubscription _statusStreamSubscription;
  StreamSubscription _gameStreamSubscription;

  SocketStream _socketStream = locator<SocketStream>();
  GameStatus _gameStatus;
  Widget _slidingPanelChild;
  String _bannerText;
  RoomProvider(
      this._room, this._status, this._gameStatus, this._currentSketcher) {
    this._slidingPanelChild = Container();
    this._bannerText = "";
    _messageStreamSubscription = _socketStream.messageStream.listen((message) {
      this.addMessage(message);
    });
    _playerStreamSubscription = _socketStream.playerStream.listen((data) {
      if (data["action"] == PlayerAction.Add) {
        this.addPlayer(data["player"] as Player);
      }
      if (data["action"] == PlayerAction.Remove) {
        this.removePlayer(data["username"] as String);
      }
    });
    _statusStreamSubscription = _socketStream.statusStream.listen((data) {
      if (data["action"] == StatusAction.RoomStatusChange) {
        this.changeRoomStatus(data["status"]);
      }
      if (data["action"] == StatusAction.GameStatusChange) {
        this.changeGameStatus(data["status"]);
      }
    });
    _gameStreamSubscription = _socketStream.gameStream.listen((data) {
      if (data["action"] == GameAction.StartTurn) {
        final String currentSketcher = data["sketcher"];
        this.setSketcher(currentSketcher);
      }
      if (data["action"] == GameAction.AddPoints) {
        this.setScore(data["username"], data["points"]);
      }
      if (data["action"] == GameAction.EndTurn ||
          data["action"] == GameAction.SkipTurn || data["action"] == GameAction.EndGame) {
        final String message = data["message"];
        this._bannerText = message;
      }
      if(data["action"] == GameAction.ChangeAdmin) {
        final String username = data["username"];
        this.changeAdmin(username);
      }
    });
  }

  List<Chat> get messages => _room.messages;

  List<Player> get players => _room.players;

  String get roomId => _room.id;

  User get roomAdmin => _room.admin;

  String get status => _status;

  Player get currentSketcher => _currentSketcher;

  GameStatus get gameStatus => _gameStatus;

  Widget get slidingPanelChild => _slidingPanelChild;

  String get bannerText => _bannerText;

  void set messages(List<Chat> newMessages) {
    _room.messages = newMessages;
    notifyListeners();
  }

  void set roomId(String id) {
    _room.id = id;
    notifyListeners();
  }

  void set admin(User player) {
    _room.admin = player;
    notifyListeners();
  }

  void set status(String status) {
    _status = status;
    notifyListeners();
  }

  void set slidingPanelChild(Widget child) {
    _slidingPanelChild = child;
    notifyListeners();
  }

  void set bannerText(String text) {
    _bannerText = text;
    notifyListeners();
  }

  void addMessage(Chat message) {
    _room.messages.add(message);
    notifyListeners();
  }

  void addPlayer(Player player) {
    _room.players.add(player);
    notifyListeners();
  }

  void setSketcher(String sketcherUsername) {
    int index = _room.players
        .indexWhere((player) => player.user.username == sketcherUsername);
    if (index != -1) {
      _currentSketcher = _room.players[index];
      notifyListeners();
    }
  }

  void setScore(String username, int points) {
    int index =
        _room.players.indexWhere((player) => player.user.username == username);
    if (index != -1) {
      _room.players[index].score += points;
      _room.players.sort((a, b) => b.score.compareTo(a.score));
      notifyListeners();
    }
  }

  void changeAdmin(String username) {
    print("======Change Admin ${username}=========");
    int index =
    _room.players.indexWhere((player) => player.user.username == username);
    if(index != -1) {
      _room.admin = _room.players[index].user;
      notifyListeners();
    }
  }

  void removePlayer(String username) {
    int index =
        _room.players.indexWhere((player) => player.user.username == username);
    if (index != -1) {
      _room.players.removeAt(index);
      notifyListeners();
    }
  }

  void changeGameStatus(GameStatus status) {
    _gameStatus = status;
    notifyListeners();
  }

  void changeRoomStatus(String status) {
    _status = status;
    notifyListeners();
  }

  void cancelStreamSubsciptions() {
    _messageStreamSubscription.cancel();
    _playerStreamSubscription.cancel();
    _statusStreamSubscription.cancel();
  }
}
