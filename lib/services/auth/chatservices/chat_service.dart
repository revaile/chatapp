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
Future<void> sendMessage(String receiverId, String message) async {
  try {
    // Ambil info pengguna saat ini
    final String currentUserId = firebaseAuth.currentUser!.uid;
    final String currentUserEmail = firebaseAuth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // Buat pesan baru
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    // Buat ID chatroom
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatroomId = ids.join('_');

    // Tambahkan pesan baru ke Firestore
    await firebaseFirestore
        .collection("chat_rooms")
        .doc(chatroomId)
        .collection("messages")
        .add(newMessage.toMap());

    print("Pesan berhasil dikirim!");
  } catch (e) {
    print("Error saat mengirim pesan: $e");
  }
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
Future<Map<String, dynamic>> getLastMessage(String userId) async {
  // Contoh implementasi, misalnya menggunakan Firebase
  final snapshot = await FirebaseFirestore.instance
      .collection('chats')
      .doc(userId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    final doc = snapshot.docs.first;
    return {
      'message': doc['message'],
      'timestamp': doc['timestamp'],
    };
  }
  return {};
}





}
