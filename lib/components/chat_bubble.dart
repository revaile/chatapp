import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  ChatBubble({super.key, required this.isCurrentUser, required this.message});
  final String message;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.green :Colors.grey.shade500,
        borderRadius: BorderRadius.circular(10)
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
      child: Text(
        message,style:const TextStyle(
          color: Colors.white,
          fontSize: 20
        ),
      ),
    );
  }
}
