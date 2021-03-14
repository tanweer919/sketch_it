import 'package:flutter/material.dart';

class SlidingDownPanel extends StatelessWidget {
  Widget child;
  SlidingDownPanel({@required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).primaryColor,
      child: child,
    );
  }
}