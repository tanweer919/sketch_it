import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  String label;
  bool inProgress;
  VoidCallback onPressed;
  double height, minWidth;
  CustomElevatedButton(
      {this.label,
      this.inProgress = false,
      this.height,
      this.minWidth,
      this.onPressed});
  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      height: height,
      minWidth: minWidth,
      // ignore: deprecated_member_use
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(color: Colors.black, width: 1.5),
          ),
          primary: Colors.white,
          minimumSize: Size(minWidth, height),
        ),
        child: inProgress
            ? Row(
              children: [
                SizedBox(
                  height: height * 0.8,
                  width: height * 0.8,
                  child: CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Color(0xff000000)),
                    ),
                ),
              ],
            )
            : Text(
                '$label',
                style: TextStyle(color: Colors.black),
              ),
        onPressed: (!inProgress) ? onPressed : () {},
      ),
    );
  }
}
