import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/RoomProvider.dart';
import '../Providers/AppProvider.dart';
import '../services/GetItLocator.dart';
import '../services/SocketIOService.dart';
import '../commons/enums.dart';
import '../models/Chat.dart';

class ChatTextField extends StatelessWidget {
  ChatTextField({Key key}) : super(key: key);
  final TextEditingController _messageController = TextEditingController();
  final SocketIOService _socketIOService = locator<SocketIOService>();
  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);
    return Consumer<RoomProvider>(
      builder: (context, model, child) => Container(
        color: Theme.of(context).accentColor,
        child: TextField(
          controller: _messageController,
          enabled: !(model.currentSketcher.user.username ==
              appProvider.currentUser.username),
          cursorColor: Colors.white,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            suffixIcon: InkWell(
              onTap: () {
                if (_messageController.text != '') {
                  final Chat message = Chat(
                      user: appProvider.currentUser,
                      message: _messageController.text,
                      messageType: MessageType.UserMessage);
                  _socketIOService.sendNewMessage(
                      roomId: model.roomId, message: message);
                  _messageController.text = '';
                }
              },
              child: Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
            hintText: 'Type anything to make a guess',
            hintStyle: TextStyle(color: Colors.white),
            contentPadding: EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0),
          ),
        ),
      ),
    );
  }
}
