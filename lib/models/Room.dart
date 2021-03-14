import 'User.dart';
import 'Chat.dart';

class Room {
  String id;
  List<Chat> messages;
  List<User> players;
  User admin;
  Room({this.id, this.messages, this.players, this.admin});
}