import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/PaintProvider.dart';
import '../commons/custom_icons.dart';
import 'StrokeColorSelector.dart';
import 'BackroundColorSelector.dart';
import 'StrokeWidthSlider.dart';

class BrushOptions extends StatefulWidget {
  const BrushOptions({Key key}) : super(key: key);

  @override
  _BrushOptionsState createState() => _BrushOptionsState();
}

class _BrushOptionsState extends State<BrushOptions> {
  bool _editOptionSelected = false;
  bool _showMenuIcon = true;
  bool _animatingMenuBackward = false;
  List<Widget> options = [];

  @override
  void initState() {
    options = [
      StrokeColorSelector(),
      BackgroundColorSelector(),
      StrokeWidthSlider()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaintProvider>(
      builder: (context, model, child) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0, left: 12.0, right: 12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Color(0xff71f6ad),
            ),
            onEnd: () {
              if (_animatingMenuBackward) {
                setState(() {
                  _showMenuIcon = true;
                });
              }
            },
            width: !_editOptionSelected
                ? 50
                : MediaQuery.of(context).size.width * 0.9,
            height: !_editOptionSelected ? 50 : 110,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _showMenuIcon
                  ? InkWell(
                      onTap: () {
                        setState(() {
                          _editOptionSelected = true;
                          _showMenuIcon = false;
                          _animatingMenuBackward = false;
                        });
                      },
                      child: Container(
                          height: 50,
                          width: 50,
                          child: Center(
                              child: Icon(
                            CustomIcons.options,
                          ))),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  model.optionsIndex = 0;
                                },
                                child: CircleAvatar(
                                  backgroundColor: model.optionsIndex == 0
                                      ? Colors.white
                                      : Color(0xff71f6ad),
                                  child: Icon(
                                    Icons.color_lens,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  model.optionsIndex = 1;
                                },
                                child: CircleAvatar(
                                  backgroundColor: model.optionsIndex == 1
                                      ? Colors.white
                                      : Color(0xff71f6ad),
                                  child: Icon(
                                    Icons.format_color_fill,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  model.optionsIndex = 2;
                                },
                                child: CircleAvatar(
                                  backgroundColor: model.optionsIndex == 2
                                      ? Colors.white
                                      : Color(0xff71f6ad),
                                  child: Icon(
                                    CustomIcons.stroke_width,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _editOptionSelected = false;
                                    _animatingMenuBackward = true;
                                  });
                                },
                                child: Icon(
                                  CustomIcons.collapse,
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: options[model.optionsIndex],
                        )
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
