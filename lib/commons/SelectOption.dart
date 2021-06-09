import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SelectOption extends StatelessWidget {
  final VoidCallback onTap;
  final String backgroundImagePath;
  final bool isSelected;
  final String label;
  SelectOption({@required this.label, @required this.backgroundImagePath, @required this.isSelected, @required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.3 ,
          height: MediaQuery.of(context).size.width * 0.3,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SvgPicture.asset(
                  backgroundImagePath,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.all(Radius.circular(10)),
                  color: Color(0X30000000),
                  border: isSelected
                      ? Border.all(
                      color: Colors.yellow, width: 3)
                      : null,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                        fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}