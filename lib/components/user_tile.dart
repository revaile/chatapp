import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key,required this.text,required this.onTap});
  final String text;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary
        ),
        margin: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.person),
            const SizedBox(width: 20,),
            Text(text,style: TextStyle(fontSize: 15,),)
          ],
        ),
      ),
    );
  }
}