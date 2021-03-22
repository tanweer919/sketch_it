import '../commons/enums.dart';
import '../constants.dart';
import 'User.dart';
class Chat{
  MessageType messageType;
  String message;
  User user;
  Chat({this.messageType, this.message, this.user});
  Chat.fromJson(Map<String, dynamic> data):
      this.messageType = stringToMessageType[data["messageType"]],
      this.message = data["message"],
      this.user = User.fromJson(data["user"]);
  Map<String, dynamic> toJson() => {
    "messageType": messageTypeToString[this.messageType],
    "message": this.message,
    "user": this.user.toJson()
  };
}