import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minimalchat/components/chat_bubble.dart';
import 'package:minimalchat/components/textfield.dart';
import 'package:minimalchat/services/auth/auth_services.dart';
import 'package:minimalchat/services/auth/chatservices/chat_service.dart';

class ChatPage extends StatefulWidget {
  ChatPage(
      {super.key, required this.recieverUsername, required this.receiverId});
  final String recieverUsername;
  final String receiverId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();
  final TextEditingController messageController = TextEditingController();
  FocusNode focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        //cause a delay so the keyboard has time to show up
        //the amouint of remaining space wil be calculated
        //then scroll down
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
  }

  void scrollDown() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  //send message
  void sendMessage(context) async {
    if (messageController.text.isNotEmpty) {
      await chatService.sendMessage(widget.receiverId, messageController.text);
      messageController.clear();
    } else {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text('Empty Message'),
              ));
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recieverUsername),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.display_settings))
        ],
      ),
      body: Column(
        children: [
          //displau all chats
          Expanded(child: _buildMessageList()),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderId = authService.getCurrentUser()!.uid;
    print(senderId);
    return StreamBuilder(
        stream: chatService.getMessage(widget.receiverId, senderId),
        builder: (context, snapShot) {
          if (snapShot.hasError) {
            return const Text('Error');
          }
          if (snapShot.connectionState == ConnectionState.waiting) {
            return const Text('Loading');
          }
          // return the listview
          return ListView(
              controller: scrollController,
              children: snapShot.data!.docs
                  .map((data) => _buildMessageItem(data))
                  .toList());
        });
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data["senderId"] == authService.getCurrentUser()!.uid;
    print(data["meassage"]);
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return Container(
        alignment: alignment,
        child: Column(
          children: [
            ChatBubble(
              message: data["meassage"],
              isCurrentUser: isCurrentUser,
            )
          ],
        ));
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              text: 'Type Your Message',
              obsecureText: false,
              controller: messageController,
              focusNode: focusNode,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
                color: Colors.green, shape: BoxShape.circle),
            margin: const EdgeInsets.only(right: 10),
            child: IconButton(
                onPressed: () {
                  sendMessage(context);
                },
                icon: const Icon(Icons.send)),
          )
        ],
      ),
    );
  }
}
