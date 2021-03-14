import 'dart:async';
import '../models/Point.dart';
import '../commons/enums.dart';
import '../models/Chat.dart';
import '../models/User.dart';
import '../models/PictionaryWord.dart';
class SocketStream {
  StreamController _pointStreamController = StreamController<Map<String, dynamic>>.broadcast();
  StreamController _messageStreamController = StreamController<Chat>.broadcast();
  StreamController _playerController = StreamController<Map<String, dynamic>>.broadcast();
  StreamController _statusController = StreamController<Map<String, dynamic>>.broadcast();
  StreamController _gameController = StreamController<Map<String,dynamic>>.broadcast();
  void addPoint(Point point) {
    _pointStreamController.sink.add({"action": DrawAction.Draw, "point": point});
  }

  void clearDrawing() {
    _pointStreamController.sink.add({"action": DrawAction.ClearDraw, "point": null});
  }

  void addNewMessage(Chat message) {
    _messageStreamController.sink.add(message);
  }

  void addPlayer(User player) {
    _playerController.sink.add({"action": PlayerAction.Add, "player" : player});
  }

  void removePlayer(User player) {
    _playerController.sink.add({"action": PlayerAction.Remove, "player": player});
  }

  void changeGameStatus(GameStatus status) {
    _statusController.sink.add({"action": StatusAction.GameStatusChange, "status": status});
  }

  void newStatus(String status) {
    _statusController.sink.add({"action": StatusAction.RoomStatusChange, "status": status});
  }

  void selectWord(List<PictionaryWord> words) {
    _gameController.sink.add({"action": GameAction.WordSelection, "words": words});
  }

  void startDrawing() {
    _gameController.sink.add({"action": GameAction.StartDrawing});
  }

  Stream<Map<String, dynamic>> get pointStream => _pointStreamController.stream.asBroadcastStream();

  Stream<Chat> get messageStream => _messageStreamController.stream;

  Stream<Map<String, dynamic>> get playerStream => _playerController.stream;

  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;

  Stream<Map<String,dynamic>> get gameStream => _gameController.stream;

  void cancelPointStream() {
    _pointStreamController.close();
  }

  void cancelMessageStream() {
    _messageStreamController.close();
  }

  void cancelPlayerStream() {
    _playerController.close();
  }

  void cancelStatusStream() {
    _statusController.close();
  }
}
