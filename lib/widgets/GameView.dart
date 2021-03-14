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
import '../services/SocketIOService.dart';
import '../Providers/AppProvider.dart';
import '../Providers/RoomProvider.dart';
import '../widgets/SlidingDownPanel.dart';
import '../services/SocketStream.dart';
import '../models/PictionaryWord.dart';
import '../widgets/WordSelectionPanel.dart';

class GameView extends StatefulWidget {
  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> with TickerProviderStateMixin {
  PaintProvider _paintProvider;
  AnimationController _slidingAnimationController;
  AnimationController _wordSelectionTimerAnimationController;
  final ScrollController _chatScrollController = ScrollController();
  TextEditingController _messageController = TextEditingController();
  SocketIOService _socketIOService = locator<SocketIOService>();
  SocketStream _socketStream = locator<SocketStream>();
  StreamSubscription _messageStreamSubscription;
  StreamSubscription _gameStreamSubscription;
  TabController _tabController;
  List<Tab> _tabList = [];
  @override
  void initState() {
    _paintProvider = locator<PaintProvider>(
      param1: <Point>[],
      param2: {
        "strokeWidth": 3.0,
        "optionsIndex": 0,
        "backgroundColor": Colors.white,
        "strokeColor": Color(0xffed3833),
      },
    );
    final RoomProvider roomProvider =
        Provider.of<RoomProvider>(context, listen: false);
    _messageStreamSubscription = _socketStream.messageStream.listen((message) {
      _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent + 40,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut);
    });
    _tabList.addAll([
      new Tab(
        text: 'Chats',
      ),
      new Tab(
        text: 'Players',
      )
    ]);
    _wordSelectionTimerAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );
    _gameStreamSubscription = _socketStream.gameStream.listen((data) {
      if (data["action"] == GameAction.WordSelection) {
        final List<PictionaryWord> pictionaryWords = data["words"];
        roomProvider.slidingPanelChild =
            WordSelectionPanel(words: pictionaryWords, animationController: _wordSelectionTimerAnimationController,);
        _slidingAnimationController.forward();
        _wordSelectionTimerAnimationController.reverse(from: 100.0);
      }
      if(data["action"] == GameAction.StartDrawing) {
        if(_slidingAnimationController.isCompleted) {
          _slidingAnimationController.reverse();
        }
      }
    });
    _tabController = new TabController(vsync: this, length: _tabList.length);
    _slidingAnimationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
  }

  @override
  void dispose() {
    _messageStreamSubscription.cancel();
    _gameStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasHeight = MediaQuery.of(context).size.height * 0.50 -
        MediaQuery.of(context).viewInsets.bottom * 0.50;
    final canvasRatio = (MediaQuery.of(context).size.width) /
        (MediaQuery.of(context).size.height * 0.50);
    final AppProvider appProvider = Provider.of<AppProvider>(context);
    return Consumer<RoomProvider>(
      builder: (context, model, child) => SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.05,
                      color: Theme.of(context).primaryColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            model.status,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => _paintProvider,
                      child: DrawingWidget(
                        canvasHeight: canvasHeight,
                        canvasWidth: canvasRatio * canvasHeight,
                      ),
                    ),
                    chatsAndPlayerSection(model: model),
                    Container(
                      color: Theme.of(context).accentColor,
                      child: TextField(
                        controller: _messageController,
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          suffixIcon: InkWell(
                            onTap: () {
                              if (_messageController.text != '') {
                                final Chat message = Chat(
                                    user: appProvider.currentUser,
                                    message: _messageController.text,
                                    messageTypes: MessageTypes.UserMessage);
                                _socketIOService.sendNewMessage(
                                    roomId: model.roomId, message: message);
                                model.addMessage(message);
                                _messageController.text = '';
                                _chatScrollController.animateTo(
                                    _chatScrollController
                                            .position.maxScrollExtent +
                                        40,
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.easeOut);
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
                ),
                AnimatedBuilder(
                  animation: _slidingAnimationController,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(
                      0,
                      -MediaQuery.of(context).size.height *
                          (1 - _slidingAnimationController.value),
                    ),
                    child: SlidingDownPanel(child: model.slidingPanelChild),
                  ),
                )
              ],
            )),
      ),
    );
  }

  Widget chatsAndPlayerSection({@required RoomProvider model}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            border:
                Border(top: BorderSide(color: Color(0x44000000), width: 0.7))),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: new TabBar(
                labelColor: Colors.black,
                labelStyle: TextStyle(
                  fontSize: 17,
                ),
                controller: _tabController,
                tabs: _tabList,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 2.0,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [chatsTab(model: model), playersTab(model: model)],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget chatsTab({@required RoomProvider model}) {
    return model.messages.length > 0
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
          );
  }

  Widget playersTab({@required RoomProvider model}) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: model.players.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image:
                              AssetImage('assets/images/user_placeholder.jpg'),
                          fit: BoxFit.cover),
                    ),
                  ),
                  Text(model.players[index].username),
                  Text('100')
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
