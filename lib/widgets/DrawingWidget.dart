import 'dart:async';
import 'package:flutter/material.dart';
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
import '../models/Chat.dart';
import '../commons/enums.dart';

class DrawingWidget extends StatefulWidget {
  final canvasHeight;
  final canvasWidth;
  DrawingWidget(
      {Key key, @required this.canvasHeight, @required this.canvasWidth})
      : super(key: key);
  @override
  _DrawingWidgetState createState() => _DrawingWidgetState();
}

class _DrawingWidgetState extends State<DrawingWidget> {
  Socket socket;
  SocketIOservice _socketIOService = locator<SocketIOservice>();
  List<Widget> options;
  bool _editOptionSelected = false;
  bool _showMenuIcon = true;
  bool _animatingMenuBackward = false;
  int seconds = 60;
  Timer _timer;
  @override
  void initState() {
    options = [
      StrokeColorSelector(),
      BackgroundColorSelector(),
      StrokeWidthSlider()
    ];
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        seconds--;
        if (seconds == 0) {
          timer.cancel();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaintProvider>(
      builder: (context, model, child) {
        return Container(
          height: widget.canvasHeight,
          width: MediaQuery.of(context).size.width,
          color: Color(0xfff5f5f5),
          child: Stack(
            children: [
              GestureDetector(
                onPanStart: (details) {
                  final RenderBox renderBox = context.findRenderObject();
                  model.addPoints(Point(
                      offset: renderBox.globalToLocal(details.globalPosition),
                      color: model.strokeColor,
                      width: model.strokeWidth));

                  _socketIOService.sendPoints(Point(
                      offset: renderBox.globalToLocal(details.globalPosition),
                      color: model.strokeColor,
                      width: model.strokeWidth));
                },
                onPanUpdate: (details) {
                  final RenderBox renderBox = context.findRenderObject();
                  model.addPoints(Point(
                      offset: renderBox.globalToLocal(details.globalPosition),
                      color: model.strokeColor,
                      width: model.strokeWidth));
                  _socketIOService.sendPoints(Point(
                      offset: renderBox.globalToLocal(details.globalPosition),
                      color: model.strokeColor,
                      width: model.strokeWidth));
                },
                onPanEnd: (details) {
                  model.addPoints(null);
                  _socketIOService.sendPoints(null);
                },
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
                            strokeWidth: model.strokeWidth),
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
                            model.points = [];
                            _socketIOService.clearDrawing();
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            color: Color(0xff71f6ad),
                            child: Icon(CustomIcons.eraser),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              editOptions(model: model)
            ],
          ),
        );
      },
    );
  }

  Widget editOptions({@required PaintProvider model}) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
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
}
