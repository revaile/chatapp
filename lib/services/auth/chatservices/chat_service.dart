import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minimalchat/models/message_model.dart';

class ChatService {
  // get instance of firestore
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  // get user stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return firebaseFirestore.collection("Users").snapshots().map((event) {
      return event.docs.map((doc) {
        // go through each individaul user
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  //send message
  Future<void> sendMessage(String receiverId, message) async {
    //get the current user info
    final String currentUserId = firebaseAuth.currentUser!.uid;
    final String currentUserEmail = firebaseAuth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    // create a new  message
    Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId,
        message: message,
        timestamp: timestamp);
    //creating a custom chat room id
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatroomId = ids.join('_');
    // add new messges to database
    await firebaseFirestore
        .collection("chat_rooms")
        .doc(chatroomId)
        .collection("messages")
        .add(newMessage.toMap());
  }
  // get messages

  Stream<QuerySnapshot> getMessage(String userId, receiverId) {
    //construct a chatroom id for the tood users
    if (receiverId == null) {
      return const Stream.empty();
    } else {
        List<String> ids = [userId, receiverId];
    ids.sort();
    String chatroomId = ids.join('_');

    return firebaseFirestore
        .collection("chat_rooms")
        .doc(chatroomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();

    }
  
  }
}
