import 'package:flutter/cupertino.dart';

class Point {
  Offset offset;
  Color color;
  double width;
  Point({this.offset, this.color, this.width});
  Map<String, dynamic> toJson() => {
    "dx": this.offset.dx,
    "dy": this.offset.dy,
    "strokeWidth": this.width,
    "strokeColor": this.color.value.toRadixString(16)
  };
}
