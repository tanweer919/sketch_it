import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/asset_provider.dart';
import 'package:flare_flutter/flare_cache.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../models/Player.dart';
import '../widgets/FinalScoreboard.dart';

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
        text: 'Scoreboard',
      )
    ]);
    _wordSelectionTimerAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );
    _gameStreamSubscription = _socketStream.gameStream.listen((data) {
      if (data["action"] == GameAction.WordSelection) {
        final List<PictionaryWord> pictionaryWords = data["words"];
        roomProvider.slidingPanelChild = WordSelectionPanel(
          words: pictionaryWords,
          animationController: _wordSelectionTimerAnimationController,
        );
        _slidingAnimationController.forward();
        _wordSelectionTimerAnimationController.reverse(from: 100.0);
      }
      if (data["action"] == GameAction.StartDrawing ||
          data["action"] == GameAction.SkipTurn) {
        if (_slidingAnimationController.isCompleted) {
          _slidingAnimationController.reverse();
        }
      }

      if (data["action"] == GameAction.EndGame) {
        List<Player> players = roomProvider.players;
        roomProvider.slidingPanelChild = FinalScoreboard(
          players: players
        );
        _slidingAnimationController.forward();
      }
    });
    _tabController = new TabController(vsync: this, length: _tabList.length);
    _slidingAnimationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    final AssetProvider assetProvider =
    AssetFlare(bundle: rootBundle, name: 'assets/rive/draw.flr');
    _warmupAnimations(assetProvider);
    super.initState();
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
                      color: Color(0xff3366ff),
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
                children: [chatsTab(model: model), scoresTab(model: model)],
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
          );
  }

  Widget scoresTab({@required RoomProvider model}) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: model.players.length,
      itemBuilder: (BuildContext context, int index) {
        Player player = model.players[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${index + 1}.',
                          style: TextStyle(fontSize: 18),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child: Container(
                              width: 30.0,
                              height: 30.0,
                              child: player.user.profilePicUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: player.user.profilePicUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Image.asset(
                                        'assets/images/user_placeholder.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/images/user_placeholder.jpg',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                        Text(
                          player.user.username,
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '${player.score}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _warmupAnimations(AssetProvider assetProvider) async {
    await cachedActor(assetProvider);
  }
}
