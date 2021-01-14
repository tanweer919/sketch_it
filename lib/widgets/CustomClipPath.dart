import 'package:flutter/material.dart';

class CustomClipPath extends CustomClipper<Path> {
  final radius = 20.0;
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width, size.height);
    path.arcToPoint(Offset(size.width - radius, size.height - radius),
        radius: Radius.circular(radius), clockwise: false);
    path.lineTo(radius,size.height - radius);
    path.arcToPoint(Offset(0, size.height -  2 * radius),
        radius: Radius.circular(radius));

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}