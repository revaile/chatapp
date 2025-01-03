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
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
  }

  void scrollDown() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    focusNode.dispose();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

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
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Text(
                widget.recieverUsername[0].toUpperCase(),
                style: const TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.recieverUsername,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildUserInput(),
          ],
        ),
      ),
    );
  }

Widget _buildMessageList() {
  String senderId = authService.getCurrentUser()!.uid;
  List<String> ids = [senderId, widget.receiverId];
  ids.sort();
  String chatroomId = ids.join('_'); // Hitung chatroomId

  return StreamBuilder(
    stream: chatService.getMessage(senderId, widget.receiverId),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(child: Text('Error loading messages'));
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      // Perbaiki pemanggilan _buildMessageItem
      return ListView(
        controller: scrollController,
        children: snapshot.data!.docs
            .map((doc) => _buildMessageItem(doc, chatroomId)) // Tambahkan chatroomId sebagai argumen
            .toList(),
      );
    },
  );
}


Widget _buildMessageItem(DocumentSnapshot doc,  String chatroomId) {
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

  // Pastikan data valid
  if (data["senderId"] == null || data["meassage"] == null) {
    return const SizedBox.shrink(); // Jangan tampilkan apa-apa jika data tidak valid
  }

  bool isCurrentUser = data["senderId"] == authService.getCurrentUser()!.uid;
  var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

  return GestureDetector(
    onLongPress: () => _deleteMessage(chatroomId, doc.id),
    child: Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ChatBubble(
        message: data["meassage"] ?? '', // Gunakan default jika null
        isCurrentUser: isCurrentUser,
      ),
    ),
  );
}

Future<void> _deleteMessage(String chatroomId, String messageId) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Delete Message"),
      content: const Text("Are you sure you want to delete this message?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            try {
              // Hapus pesan dari subkoleksi
              await FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(chatroomId)
                  .collection('messages')
                  .doc(messageId)
                  .delete();
              
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Message deleted successfully")),
              );
            } catch (e) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to delete message: $e")),
              );
            }
          },
          child: const Text("Delete"),
        ),
      ],
    ),
  );
}


Widget _buildUserInput() {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: messageController,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: 'Type a message...',
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              sendMessage(context);
            },
            icon: const Icon(Icons.send, color: Colors.white),
          ),
        )
      ],
    ),
  );
}

}
