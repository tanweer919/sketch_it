import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

class GameOverlay extends StatelessWidget {
  final double canvasHeight;
  final double canvasWidth;
  final String text;
  const GameOverlay({Key key, this.canvasHeight, this.canvasWidth, this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: canvasHeight,
        width: canvasWidth,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 3,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: FlareActor(
                          "assets/rive/draw.flr",
                          alignment: Alignment.center,
                          fit: BoxFit.contain,
                          animation: "draw_hexagon",
                          callback: (value) {},
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.12,
                          child: Text(
                            text,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xff3366ff),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
