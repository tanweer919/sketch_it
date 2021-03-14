import 'dart:async';
import 'package:flutter/material.dart';
import '../models/Point.dart';
import '../services/GetItLocator.dart';
import '../services/SocketStream.dart';
import '../commons/enums.dart';

class PaintProvider extends ChangeNotifier {
  List<Point> _points;
  double _strokeWidth;
  int _optionsIndex;
  Color _backgroundColor;
  Color _strokeColor;
  SocketStream _socketStream = locator<SocketStream>();
  StreamSubscription _pointStreamSubscription;

  PaintProvider(
      this._points,
      this._strokeWidth,
      this._optionsIndex,
      this._backgroundColor,
      this._strokeColor,) {
    _pointStreamSubscription = _socketStream.pointStream.listen((data) {
      if (data["action"] == DrawAction.Draw) {
        this.addPoint(data["point"]);
      }
      if (data["action"] == DrawAction.ClearDraw) {
        this.points = [];
      }
    });
  }

  List<Point> get points => _points;

  double get strokeWidth => _strokeWidth;

  int get optionsIndex => _optionsIndex;

  Color get backgroundColor => _backgroundColor;

  Color get strokeColor => _strokeColor;

  void set points(List<Point> drawPoints) {
    _points = drawPoints;
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


  void addPoint(Point point) {
    _points.add(point);
    notifyListeners();
  }

  void cancelStreamSubsciptions() {
    _pointStreamSubscription.cancel();
  }
}
