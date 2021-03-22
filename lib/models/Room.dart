import 'User.dart';
import 'Chat.dart';
import 'Player.dart';

class Room {
  String id;
  List<Chat> messages;
  List<Player> players;
  User admin;
  Room({this.id, this.messages, this.players, this.admin});
}