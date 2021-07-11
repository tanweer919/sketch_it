import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'ChatCard.dart';
import '../commons/enums.dart';
import '../Providers/RoomProvider.dart';
import 'dart:async';
import '../services/SocketStream.dart';
import '../services/GetItLocator.dart';

class ChatsTab extends StatefulWidget {
  const ChatsTab({Key key}) : super(key: key);

  @override
  _ChatsTabState createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  final ScrollController _chatScrollController = ScrollController();
  StreamSubscription _messageStreamSubscription;
  final SocketStream _socketStream = locator<SocketStream>();

  @override
  void initState() {
    //Sunscribe to the message stream
    _messageStreamSubscription = _socketStream.messageStream.listen((message) {
      //When a new message arrives scroll down to the bottom
      _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent + 40,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut);
    });
    super.initState();
  }

  @override
  void dispose() {
    //Cancel subscription to the message stream
    _messageStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, model, child) => model.messages.length > 0
          ? ListView.builder(
              controller: _chatScrollController,
              shrinkWrap: true,
              itemCount: model.messages.length,
              itemBuilder: (BuildContext context, int index) {
                return ChatCard(
                  message: model.messages[index],
                  isCorrect: model.messages[index].messageType ==
                      MessageType.PointsGained,
                );
              },
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: SvgPicture.asset(
                      'assets/images/empty.svg',
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Wow, so empty. Start making guesses.',
                      style: TextStyle(color: Color(0x55000000)),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
