import 'package:flutter/material.dart';

class WaveClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final firstControlPoint = Offset(size.width / 4, size.height - 30);
    final firstEndPoint = Offset(size.width * 0.37, size.height - 55);
    final secondControlPoint = Offset(size.width / 2, size.height - 75);
    final secondEndPoint = Offset(size.width * 0.62, size.height - 30);
    final thirdControlPoint = Offset(size.width * 0.75, size.height);
    final thirdEndPoint = Offset(size.width, size.height - 90);

    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.quadraticBezierTo(thirdControlPoint.dx, thirdControlPoint.dy, thirdEndPoint.dx, thirdEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}