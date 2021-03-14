import 'dart:math';
import 'dart:ui';
import '../models/Point.dart';

import 'package:flutter/material.dart';

class SketchPainter extends CustomPainter {
  final List<Point> offsets;
  final double strokeWidth;
  final Color strokeColor;
  final canvasRatio;
  SketchPainter({@required this.offsets, @required this.strokeWidth, @required this.strokeColor, @required this.canvasRatio});


  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    Paint paint = Paint()
    ..isAntiAlias = true;
    canvas.clipRect(rect);

    for(int i = 0; i < offsets.length - 1; i++) {
      if(offsets[i] != null){
        paint.color = offsets[i].color;
        paint.strokeWidth = offsets[i].width;
      }
      if(offsets[i] != null && offsets[i + 1] != null) {
        canvas.drawLine(modifiedOffset(offsets[i].offset), modifiedOffset(offsets[i+1].offset), paint);
      }
      if(offsets[i] != null && offsets[i + 1] == null) {
        canvas.drawPoints(PointMode.points, [modifiedOffset(offsets[i].offset)], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SketchPainter oldDelegate) {
    return true;
  }

  Offset modifiedOffset(Offset initialOffset) {

    return Offset(initialOffset.dx * canvasRatio, initialOffset.dy * canvasRatio);
  }
}