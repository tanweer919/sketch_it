import 'package:flutter/material.dart';

class LargeButton extends StatelessWidget {
  bool inProgress = false;
  bool buttonPressed = false;
  double width;
  Widget child;
  VoidCallback onTap;
  bool isPrimaryColor;
  LargeButton(
      {@required this.child,
      this.inProgress = false,
      @required this.buttonPressed,
      @required this.width,
      @required this.onTap,
      this.isPrimaryColor = true});

  @override
  Widget build(BuildContext context) {
    double imageRatio = isPrimaryColor ? (buttonPressed ? (47 / 193) : (59 / 196)) : (buttonPressed ? (47 / 193) : (56 / 196));
    String assetName = isPrimaryColor
        ? (buttonPressed
            ? 'assets/images/buttons_large_yellow_active.png'
            : 'assets/images/buttons_large_yellow.png')
        : (buttonPressed
            ? 'assets/images/buttons_large_green_active.png'
            : 'assets/images/buttons_large_green.png');
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: width * imageRatio,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(assetName),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: buttonPressed ? 0.0 : 16.0),
            child: !inProgress
                ? child
                : CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                      Color(0xfff5f5f5),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
