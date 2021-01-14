import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/PaintProvider.dart';

class StrokeWidthSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PaintProvider>(builder: (context, model, child) {
      return Slider(
        onChanged: (double value) {
          model.strokeWidth = value;
        },
        value: model.strokeWidth,
        min: 1.0,
        max: 6.0,
        divisions: 5,
        label: '${model.strokeWidth}',
      );
    });
  }
}
