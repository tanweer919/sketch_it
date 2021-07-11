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
import 'ChatAndScoresWidget.dart';
import 'ChatTextField.dart';

class GameView extends StatefulWidget {
  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> with TickerProviderStateMixin {
  PaintProvider _paintProvider;
  AnimationController _slidingAnimationController;
  AnimationController _wordSelectionTimerAnimationController;
  SocketStream _socketStream = locator<SocketStream>();
  StreamSubscription _gameStreamSubscription;
  
  @override
  void initState() {
    //Initial brush setting
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

    //Animation Controller for word selection widget
    _wordSelectionTimerAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );

    //Subscribe to Game stream
    _gameStreamSubscription = _socketStream.gameStream.listen((data) {
      if (data["action"] == GameAction.WordSelection) {
        //If event is word selection
        //Get the three words to show
        final List<PictionaryWord> pictionaryWords = data["words"];

        //Display word selection widget in the sliding panel
        roomProvider.slidingPanelChild = WordSelectionPanel(
          words: pictionaryWords,
          animationController: _wordSelectionTimerAnimationController,
        );

        //Run silding animation
        _slidingAnimationController.forward();

        //Run timer animation in reverse
        _wordSelectionTimerAnimationController.reverse(from: 100.0);
      }
      if (data["action"] == GameAction.StartDrawing ||
          data["action"] == GameAction.SkipTurn) {
        //If the word is selected or turn is skipped
        if (_slidingAnimationController.isCompleted) {
          //Retract the sliding panel
          _slidingAnimationController.reverse();
        }
      }

      if (data["action"] == GameAction.EndGame) {
        //If game ended
        List<Player> players = roomProvider.players;

        //Display scoreboard widget in the sliding panel
        roomProvider.slidingPanelChild = FinalScoreboard(
          players: players
        );

        //Run the animation
        _slidingAnimationController.forward();
      }
    });

    //Sliding animation controller
    _slidingAnimationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);

    //Asset provider for flare    
    final AssetProvider assetProvider =
    AssetFlare(bundle: rootBundle, name: 'assets/rive/draw.flr');
    _warmupAnimations(assetProvider);
    super.initState();
  }

  @override
  void dispose() {
    //Cancel subscription to the game stream
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
                    ChatsAndScoresWidget(),
                    ChatTextField(),
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
                ),
              ],
            ),
        ),
      ),
    );
  }


  Future<void> _warmupAnimations(AssetProvider assetProvider) async {
    await cachedActor(assetProvider);
  }
}
