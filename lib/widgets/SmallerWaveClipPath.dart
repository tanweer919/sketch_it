import 'package:flutter/material.dart';

class SmallerWaveClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final firstControlPoint = Offset(size.width * 0.2 , size.height);
    final firstEndPoint = Offset(size.width * 0.4, size.height * 0.5);
    final secondControlPoint = Offset(size.width * 0.7, 0);
    final secondEndPoint = Offset(size.width, size.height);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
