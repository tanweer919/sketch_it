import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Chat.dart';
import '../commons/enums.dart';
import '../commons/custom_icons.dart';
import '../Providers/AppProvider.dart';

class ChatCard extends StatelessWidget {
  final bool isCorrect;
  final Chat message;
  ChatCard({this.isCorrect, this.message});
  Map<MessageTypes, IconData> icons = {
    MessageTypes.UserMessage: Icons.edit,
    MessageTypes.JoinedRoom: CustomIcons.enter_room,
    MessageTypes.LeftRoom: CustomIcons.leave_room
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: isCorrect ? Colors.green : Colors.white,
          border:
              Border(bottom: BorderSide(color: Color(0x33000000), width: 0.7))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(
                icons[message.messageTypes],
                color: isCorrect ? Colors.white : Color(0xff3366ff),
                size: 15,
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: displayMessage(message, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget displayMessage(Chat message, BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);
    String username = (appProvider.currentUser == message.user)
        ? 'You'
        : message.user.username;
    Map<MessageTypes, String> generatedMessage = {
      MessageTypes.UserMessage: '${username}: ',
      MessageTypes.JoinedRoom: '${username} has joined the room',
      MessageTypes.LeftRoom: '${username} has left the room',
    };
    return RichText(
        text: TextSpan(
            style: TextStyle(
              color: isCorrect ? Colors.white : Color(0xff3366ff),
            ),
            children: [
          TextSpan(
              text: generatedMessage[message.messageTypes],
              style: TextStyle(fontWeight: FontWeight.w500)),
          if (message.messageTypes == MessageTypes.UserMessage)
            TextSpan(
                text: message.message,
                style:
                    TextStyle(color: isCorrect ? Colors.white : Colors.black))
        ]));
  }
}
