import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_sketch/Providers/AppProvider.dart';
import 'package:provider/provider.dart';
import 'SketchPainter.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../services/SocketIOService.dart';
import '../services/GetItLocator.dart';
import '../Providers/PaintProvider.dart';
import '../models/Point.dart';
import '../commons/custom_icons.dart';
import 'ShareRoomModal.dart';
import '../Providers/RoomProvider.dart';
import '../commons/LargeYellowButton.dart';
import '../commons/enums.dart';
import '../models/User.dart';
import '../services/SocketStream.dart';
import '../models/Player.dart';
import 'GameOverlay.dart';
import 'BrushOptions.dart';

class DrawingCanvas extends StatefulWidget {
  final double canvasHeight;
  final double canvasWidth;
  DrawingCanvas({
    Key key,
    @required this.canvasHeight,
    @required this.canvasWidth,
  }) : super(key: key);
  @override
  _DrawingCanvasState createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas>
    with SingleTickerProviderStateMixin {
  Socket socket;
  SocketIOService _socketIOService = locator<SocketIOService>();
  AnimationController
      _gameOverlayAnimationController; //Animation controller for game overlay
  Timer _secondsLeftToDrawTimer; //Seconds left in the room
  SocketStream _socketStream = locator<SocketStream>();
  StreamSubscription _gameStreamSubscription;
  int seconds = 60;
  bool _shareRoomButtonPressed = false;
  @override
  void initState() {
    _gameOverlayAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    //Subscribe to the game stream
    _gameStreamSubscription = _socketStream.gameStream.listen(
      (data) {
        if (data["action"] == GameAction.StartDrawing) {
          //Start the timer when start drawing event occur
          setState(() {
            seconds = 60;
          });

          //Set interval to decrease timer every second
          _secondsLeftToDrawTimer = Timer.periodic(
            Duration(seconds: 1),
            (timer) {
              setState(
                () {
                  if (seconds > 0) {
                    seconds--;
                  }
                },
              );
            },
          );
        }
        if (data["action"] == GameAction.EndTurn ||
            data["action"] == GameAction.SkipTurn) {
          //If turn is ended
          //Stop the timer
          if (_secondsLeftToDrawTimer != null) {
            _secondsLeftToDrawTimer.cancel();
          }

          //Clear canvas
          _socketStream.clearDrawing();

          //Run the game overlay animation
          _gameOverlayAnimationController.forward();
        }
        if (data["action"] == GameAction.StartTurn) {
          //If turn starts
          if (_gameOverlayAnimationController.isCompleted) {
            //If gameOverlayAnimationController is completed
            //Run the game overlay animation to 200%, so the overlay slides to the right side out of view
            _gameOverlayAnimationController.animateTo(2.0);

            //After that, reset the animation to the initial state
            _gameOverlayAnimationController.reset();
          }
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _gameStreamSubscription.cancel();
    _secondsLeftToDrawTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User player = Provider.of<AppProvider>(context).currentUser;
    return Consumer<RoomProvider>(
      builder: (context, roomModel, child) => Consumer<PaintProvider>(
        builder: (context, model, child) => Container(
          height: widget.canvasHeight,
          width: MediaQuery.of(context).size.width,
          color: Color(0xfff5f5f5),
          child: Stack(
            children: [
              GestureDetector(
                onPanStart: isSketcher(
                        currentSketcher: roomModel.currentSketcher,
                        player: player)
                    ? (details) {
                        final RenderBox renderBox = context.findRenderObject();
                        model.addPoint(Point(
                            offset:
                                renderBox.globalToLocal(details.globalPosition),
                            color: model.strokeColor,
                            width: model.strokeWidth));

                        _socketIOService.sendPoints(
                            roomId: roomModel.roomId,
                            point: Point(
                                offset: renderBox
                                    .globalToLocal(details.globalPosition),
                                color: model.strokeColor,
                                width: model.strokeWidth));
                      }
                    : null,
                onPanUpdate: isSketcher(
                        currentSketcher: roomModel.currentSketcher,
                        player: player)
                    ? (details) {
                        final RenderBox renderBox = context.findRenderObject();
                        model.addPoint(Point(
                            offset:
                                renderBox.globalToLocal(details.globalPosition),
                            color: model.strokeColor,
                            width: model.strokeWidth));
                        _socketIOService.sendPoints(
                            roomId: roomModel.roomId,
                            point: Point(
                                offset: renderBox
                                    .globalToLocal(details.globalPosition),
                                color: model.strokeColor,
                                width: model.strokeWidth));
                      }
                    : null,
                onPanEnd: isSketcher(
                        currentSketcher: roomModel.currentSketcher,
                        player: player)
                    ? (details) {
                        model.addPoint(null);
                        _socketIOService.sendPoints(
                            roomId: roomModel.roomId, point: null);
                      }
                    : null,
                child: Center(
                  child: Container(
                    height: widget.canvasHeight,
                    width: widget.canvasWidth,
                    color: model.backgroundColor,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: Size(
                          widget.canvasWidth,
                          widget.canvasHeight,
                        ),
                        painter: SketchPainter(
                            offsets: model.points,
                            strokeColor: model.strokeColor,
                            strokeWidth: model.strokeWidth,
                            canvasRatio: widget.canvasWidth /
                                MediaQuery.of(context).size.width),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        child: Container(
                          height: 50,
                          width: 50,
                          color: Colors.red,
                          child: Center(
                              child: Text(
                            '$seconds',
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          )),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        child: InkWell(
                          onTap: () {
                            showShareRoomModal(roomModel: roomModel);
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            color: Color(0xff71f6ad),
                            child: Icon(Icons.share),
                          ),
                        ),
                      ),
                    ),
                    if (isSketcher(
                        currentSketcher: roomModel.currentSketcher,
                        player: player))
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          child: InkWell(
                            onTap: () {
                              model.points = [];
                              _socketIOService.clearDrawing(
                                  roomId: roomModel.roomId);
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              color: Color(0xff71f6ad),
                              child: Icon(CustomIcons.eraser),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isSketcher(
                  currentSketcher: roomModel.currentSketcher, player: player))
                Align(
                  alignment: Alignment.bottomRight,
                  child: BrushOptions(),
                ),
              if (roomModel.gameStatus == GameStatus.NotStarted)
                Container(
                  height: widget.canvasHeight,
                  width: MediaQuery.of(context).size.width,
                  color: Color(0X70000000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: (roomModel.roomAdmin.username == player.username)
                        ? [
                            Flexible(
                              fit: FlexFit.loose,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  roomModel.players.length > 1
                                      ? '${roomModel.players.length - 1} players have joined'
                                      : 'Waiting for other players to join before you can start the game...',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            (roomModel.players.length > 1)
                                ? LargeButton(
                                    buttonPressed: false,
                                    onTap: () {
                                      _socketIOService.startGame(
                                          roomId: roomModel.roomId,
                                          username: player.username);
                                    },
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: Text(
                                      'Start the game',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  )
                                : LargeButton(
                                    buttonPressed: _shareRoomButtonPressed,
                                    onTap: () {
                                      setState(() {
                                        _shareRoomButtonPressed = true;
                                      });
                                      Timer(Duration(milliseconds: 200), () {
                                        setState(() {
                                          _shareRoomButtonPressed = false;
                                        });
                                      });
                                      showShareRoomModal(roomModel: roomModel);
                                    },
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: Text(
                                      'Share the room',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                          ]
                        : [
                            Flexible(
                              fit: FlexFit.loose,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Waiting for admin to start the game...',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            LargeButton(
                              buttonPressed: false,
                              onTap: () {
                                showShareRoomModal(roomModel: roomModel);
                              },
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(
                                'Share the room',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ],
                  ),
                ),
              AnimatedBuilder(
                animation: _gameOverlayAnimationController,
                builder: (context, child) => Transform.translate(
                  offset: Offset(
                      -MediaQuery.of(context).size.width *
                          (1 - _gameOverlayAnimationController.value),
                      0),
                  child: GameOverlay(text: roomModel.bannerText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

//  void handleReceivePoint(Map<String, dynamic> data) {
//    print(data);
//    PaintProvider paintProvider = Provider.of<PaintProvider>(context);
//    List<Point> newPoints = [...paintProvider.points];
//    newPoints.add(Point(
//        offset: Offset(data["dx"], data["dy"]),
//        width: data["strokeWidth"].toDouble(),
//        color: Colors.black));
//    paintProvider.points = newPoints;
//  }

  bool isSketcher({Player currentSketcher, User player}) {
    return currentSketcher.user.username == player.username;
  }

  void showShareRoomModal({RoomProvider roomModel}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        child: ShareRoomModal(
          roomId: roomModel.roomId,
          roomCreated: false,
        ),
      ),
    );
  }
}
