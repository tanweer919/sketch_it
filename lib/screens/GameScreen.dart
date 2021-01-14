import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../Providers/PaintProvider.dart';
import '../services/GetItLocator.dart';
import '../widgets/DrawingWidget.dart';
import '../models/Point.dart';
import '../widgets/ChatCard.dart';
import '../models/Chat.dart';
import '../commons/enums.dart';

class GameScreen extends StatefulWidget {
  final message;
  GameScreen({Key key, this.message}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  PaintProvider _paintProvider;
  final ScrollController _chatScrollController = ScrollController();
  TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    _paintProvider = locator<PaintProvider>(
      param1: <Point>[],
      param2: {
        "strokeWidth": 3.0,
        "optionsIndex": 0,
        "backgroundColor": Colors.white,
        "strokeColor": Color(0xffed3833)
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canvasHeight = MediaQuery.of(context).size.height * 0.6 -
        MediaQuery.of(context).viewInsets.bottom * 0.6;
    final canvasRatio = (MediaQuery.of(context).size.width) /
        (MediaQuery.of(context).size.height * 0.6);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: ChangeNotifierProvider(
            create: (context) => _paintProvider,
            child: Consumer<PaintProvider>(
              builder: (context, model, child) {
                return Column(
                  children: [
                    DrawingWidget(
                      canvasHeight: canvasHeight,
                      canvasWidth: canvasRatio * canvasHeight,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Color(0x44000000), width: 0.7))),
                        child: model.messages.length > 0
                            ? ListView.builder(
                                controller: _chatScrollController,
                                shrinkWrap: true,
                                itemCount: model.messages.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return index != 0 && index % 5 == 0
                                      ? ChatCard(
                                          message: model.messages[index],
                                          isCorrect: true,
                                        )
                                      : ChatCard(
                                          message: model.messages[index],
                                          isCorrect: false,
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Wow, so empty. Start making guesses.', style: TextStyle(color: Color(0x55000000)),),
                                    )
                                  ],
                                ),
                              ),
                      ),
                    ),
                    Container(
                      color: Color(0xff5bc777),
                      child: TextField(
                        controller: _messageController,
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          suffixIcon: InkWell(
                            onTap: () {
                              if(_messageController.text != '') {
                                model.addMessages(Chat(
                                    message: _messageController.text,
                                    messageTypes: MessageTypes.UserMessage));
                                _messageController.text = '';
                                _chatScrollController.animateTo(
                                    _chatScrollController.position.maxScrollExtent + 40,
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.easeOut
                                );
                              }
                            },
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                          hintText: 'Type anything to make a guess',
                          hintStyle: TextStyle(color: Colors.white),
                          contentPadding:
                              EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0),
                        ),
                      ),
                    )
                  ],
                );
              },
            )),
      ),
    );
  }
}
