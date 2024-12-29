import 'package:flutter/material.dart';
import 'package:minimalchat/components/drawer.dart';
import 'package:minimalchat/components/user_tile.dart';
import 'package:minimalchat/pages/chat_page.dart';
import 'package:minimalchat/services/auth/auth_services.dart';
import 'package:minimalchat/services/auth/chatservices/chat_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Shadow Chat'),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.grey,
          elevation: 0,
          actions:[
            IconButton(onPressed: (){}, icon:Icon(Icons.search_rounded,size: 30,))
          ]
        ),
        drawer: const CustomDrawer(),
        body: _buildUser());
  }

  Widget _buildUser() {
    return StreamBuilder(
        stream: _chatService.getUsersStream(),
        builder: (context, snapShot) {
          //errors
          if (snapShot.hasError) {
            return const Text('Error');
          }
          //loading
          if (snapShot.connectionState == ConnectionState.waiting) {
            return const Text('Loading');
          }
          //listview
          return ListView(
            children: snapShot.data!
                .map<Widget>((userData) => _buildUserState(userData, context))
                .toList(),
          );
        });
  }

  Widget _buildUserState(Map<String, dynamic> userData, BuildContext context) {
    // display all user expect current tile
    if (userData['email'] != _authService.getCurrentUser()!.email) {
      print(userData['username']);
      return UserTile(
        text: userData['username'],
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                        recieverUsername: userData["username"],
                        receiverId: userData["uid"],
                      )));
        },
      );
    } else {
      return Container();
    }
  }
}
