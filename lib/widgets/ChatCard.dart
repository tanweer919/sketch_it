import 'package:flutter/material.dart';
import '../models/Chat.dart';
import '../commons/enums.dart';
class ChatCard extends StatelessWidget {
  final bool isCorrect;
  final Chat message;
  ChatCard({this.isCorrect, this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green : Colors.white,
        border: Border(bottom: BorderSide(color: Color(0x33000000), width: 0.7))
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(Icons.edit, color: isCorrect ? Colors.white : Color(0xff3366ff), size: 15,),
            ),
            Text('Tanweer: ', style: TextStyle(color: isCorrect ? Colors.white : Color(0xff3366ff), fontWeight: FontWeight.w500),),
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                message.message,
                style: TextStyle(color: isCorrect ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
