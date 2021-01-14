import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/PaintProvider.dart';

class StrokeColorSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PaintProvider>(builder: (context, model, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          strokeColorTile(model: model, color: Color(0xffed3833)),
          strokeColorTile(model: model, color: Color(0xff54b848)),
          strokeColorTile(model: model, color: Color(0xff2a8ff7)),
          strokeColorTile(model: model, color: Color(0xfff8c446)),
          strokeColorTile(model: model, color: Colors.black),
          strokeColorTile(model: model, color: Colors.white)
        ],
      );
    });
  }

  Widget strokeColorTile(
      {@required PaintProvider model, @required Color color}) {
    return InkWell(
      onTap: () {
        model.strokeColor = color;
      },
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: color == model.strokeColor
            ? Center(
                child: Icon(
                  Icons.check,
                  color: color != Colors.white ? Colors.white : Colors.black,
                ),
              )
            : Container(),
      ),
    );
  }
}
