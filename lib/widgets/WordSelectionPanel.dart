import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/PictionaryWord.dart';
import '../widgets/CustomTimerPainter.dart';
import '../services/GetItLocator.dart';
import '../services/SocketIOService.dart';
import '../commons/LargeYellowButton.dart';
import '../Providers/RoomProvider.dart';

class WordSelectionPanel extends StatefulWidget {
  final List<PictionaryWord> words;
  final AnimationController animationController;
  WordSelectionPanel({@required this.words, @required this.animationController});

  @override
  _WordSelectionPanelState createState() => _WordSelectionPanelState();
}

class _WordSelectionPanelState extends State<WordSelectionPanel> with TickerProviderStateMixin {
  StreamSubscription _gameStreamSubscription;
  SocketIOService _socketIOService = locator<SocketIOService>();
  List<bool> _buttonPressed;

  @override
  void initState() {
    
    _buttonPressed = List.generate(widget.words.length, (index) => false);
    super.initState();
  }
  
  @override
  void dispose() {
    _gameStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, model, child) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Stack(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      child: CustomPaint(
                        painter: CustomTimerPainter(
                          animation: widget.animationController,
                          backgroundColor: Colors.white,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: widget.animationController,
                      builder: (context, child) => Container(
                        height: 50,
                        width: 50,
                        child: Center(
                          child: Text(
                            '${(20 * (widget.animationController.value)).ceil()}',
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Select a word to draw',
              style: TextStyle(fontSize: 40, fontFamily: 'CaveatBrush'),
              textAlign: TextAlign.center,
            ),
          ),
          for (int i = 0; i < widget.words.length; i++)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LargeButton(
                  child: Text(
                    widget.words[i].word,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  buttonPressed: _buttonPressed[i],
                  width: MediaQuery.of(context).size.width * 0.6,
                  onTap: () {
                    List<bool> isButtonPressed = [..._buttonPressed];
                    isButtonPressed[i] = true;
                    setState(() {
                      _buttonPressed = isButtonPressed;
                    });
                    Timer(Duration(milliseconds: 50), () {
                      isButtonPressed[i] = false;
                      setState(() {
                        _buttonPressed = isButtonPressed;
                      });
                    });
                    _socketIOService.wordSelected(
                        word: widget.words[i].word, roomId: model.roomId);
                  },
                  isPrimaryColor: false),
            )
        ],
      ),
    );
  }
}
