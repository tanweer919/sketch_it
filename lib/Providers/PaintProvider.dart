import 'package:flutter/material.dart';
import '../models/Point.dart';
import '../services/GetItLocator.dart';
import '../services/SocketStream.dart';
import '../commons/enums.dart';
import '../models/Chat.dart';
class PaintProvider extends ChangeNotifier {
  List<Point> _points;
  double _strokeWidth;
  int _optionsIndex;
  Color _backgroundColor;
  Color _strokeColor;
  SocketStream _socketStream = locator<SocketStream>();
  List<Chat> _messages;
  PaintProvider(this._points, this._messages, this._strokeWidth, this._optionsIndex, this._backgroundColor,
      this._strokeColor) {
    _socketStream.pointStream.listen((data) {
      if(data["action"] == DrawAction.Draw) {
        this.addPoints(data["point"]);
      }
      if(data["action"] == DrawAction.ClearDraw) {
        this.points = [];
      }
    });
  }

  List<Point> get points => _points;

  List<Chat> get messages => _messages;

  double get strokeWidth => _strokeWidth;

  int get optionsIndex => _optionsIndex;

  Color get backgroundColor => _backgroundColor;

  Color get strokeColor => _strokeColor;

  void set points(List<Point> drawPoints) {
    _points = drawPoints;
    notifyListeners();
  }

  void set messages(List<Chat> newMessages) {
    _messages = newMessages;
    notifyListeners();
  }

  void set strokeWidth(double width) {
    _strokeWidth = width;
    notifyListeners();
  }

  void set optionsIndex(int index) {
    _optionsIndex = index;
    notifyListeners();
  }

  void set backgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }

  void set strokeColor(Color color) {
    _strokeColor = color;
    notifyListeners();
  }

  void addPoints(Point point) {
    _points.add(point);
    notifyListeners();
  }

  void addMessages(Chat message) {
    _messages.add(message);
    notifyListeners();
  }
}