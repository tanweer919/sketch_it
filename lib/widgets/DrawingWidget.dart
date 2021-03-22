import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_sketch/Providers/AppProvider.dart';
import 'package:provider/provider.dart';
import 'SketchPainter.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'BackroundColorSelector.dart';
import 'StrokeColorSelector.dart';
import 'StrokeWidthSlider.dart';
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
import 'dart:async';
import '../models/Player.dart';

class DrawingWidget extends StatefulWidget {
  final canvasHeight;
  final canvasWidth;
  DrawingWidget({
    Key key,
    @required this.canvasHeight,
    @required this.canvasWidth,
  }) : super(key: key);
  @override
  _DrawingWidgetState createState() => _DrawingWidgetState();
}

class _DrawingWidgetState extends State<DrawingWidget> {
  Socket socket;
  SocketIOService _socketIOService = locator<SocketIOService>();
  List<Widget> options;
  bool _editOptionSelected = false;
  bool _showMenuIcon = true;
  bool _animatingMenuBackward = false;
  Timer _secondsLeftToDrawTimer;
  SocketStream _socketStream = locator<SocketStream>();
  StreamSubscription _gameStreamSubscription;
  int seconds = 60;
  @override
  void initState() {
    options = [
      StrokeColorSelector(),
      BackgroundColorSelector(),
      StrokeWidthSlider()
    ];

    _gameStreamSubscription = _socketStream.gameStream.listen(
      (data) {
        if (data["action"] == GameAction.StartDrawing) {
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
        if (data["action"] == GameAction.StartTurn) {}
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
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) => Dialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      elevation: 0,
                                      backgroundColor: Colors.white,
                                      child: ShareRoomModal(
                                        roomId: roomModel.roomId,
                                        roomCreated: false,
                                      ),
                                    ));
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
                  child: editOptions(model: model),
                ),
              if (roomModel.gameStatus == GameStatus.NotStarted)
                Container(
                  height: widget.canvasHeight,
                  width: widget.canvasWidth,
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
                            if (roomModel.players.length > 1)
                              LargeButton(
                                buttonPressed: false,
                                onTap: () {
                                  _socketIOService.startGame(
                                      roomId: roomModel.roomId,
                                      username: player.username);
                                },
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  'Start the game',
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
                            )
                          ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget editOptions({@required PaintProvider model}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 12.0, right: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(30.0)),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Color(0xff71f6ad),
          ),
          onEnd: () {
            if (_animatingMenuBackward) {
              setState(() {
                _showMenuIcon = true;
              });
            }
          },
          width: !_editOptionSelected
              ? 50
              : MediaQuery.of(context).size.width * 0.9,
          height: !_editOptionSelected ? 50 : 110,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _showMenuIcon
                ? InkWell(
                    onTap: () {
                      setState(() {
                        _editOptionSelected = true;
                        _showMenuIcon = false;
                        _animatingMenuBackward = false;
                      });
                    },
                    child: Container(
                        height: 50,
                        width: 50,
                        child: Center(
                            child: Icon(
                          CustomIcons.options,
                        ))),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                model.optionsIndex = 0;
                              },
                              child: CircleAvatar(
                                backgroundColor: model.optionsIndex == 0
                                    ? Colors.white
                                    : Color(0xff71f6ad),
                                child: Icon(
                                  Icons.color_lens,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                model.optionsIndex = 1;
                              },
                              child: CircleAvatar(
                                backgroundColor: model.optionsIndex == 1
                                    ? Colors.white
                                    : Color(0xff71f6ad),
                                child: Icon(
                                  Icons.format_color_fill,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                model.optionsIndex = 2;
                              },
                              child: CircleAvatar(
                                backgroundColor: model.optionsIndex == 2
                                    ? Colors.white
                                    : Color(0xff71f6ad),
                                child: Icon(
                                  CustomIcons.stroke_width,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _editOptionSelected = false;
                                  _animatingMenuBackward = true;
                                });
                              },
                              child: Icon(
                                CustomIcons.collapse,
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: options[model.optionsIndex],
                      )
                    ],
                  ),
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
}
