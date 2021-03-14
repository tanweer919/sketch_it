import '../commons/enums.dart';
import '../constants.dart';
import 'User.dart';
class Chat{
  MessageTypes messageTypes;
  String message;
  User user;
  Chat({this.messageTypes, this.message, this.user});
  Chat.fromJson(Map<String, dynamic> data):
      this.messageTypes = stringToMessageTypes[data["messageType"]],
      this.message = data["message"],
      this.user = User.fromJson(data["user"]);
  Map<String, dynamic> toJson() => {
    "messageType": messageTypesToString[this.messageTypes],
    "message": this.message,
    "user": this.user.toJson()
  };
}