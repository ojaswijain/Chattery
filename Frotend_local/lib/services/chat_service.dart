import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_media_app/models/message.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:http/http.dart' as http;
class ChatService {
  final baseUrl = 'https://b26d-123-201-104-16.ngrok.io';

  sendMessage(Message message,String receiver) async {
    //will send message to chats collection with the usersId
    await http.post(Uri.parse('$baseUrl/api/chat'), body: {
    'receiver':receiver,
    'type': message.type.toString(),
    'time': message.time.toString(),
    'sender':message.senderUid,
    'content':message.content,
    });
   // await chatRef.doc("$chatId").update({"lastTextTime": Timestamp.now()});
  }

  Future<String> uploadImage(File image, String chatId) async {
    Reference storageReference =
        storage.ref().child("chats").child(chatId).child(uuid.v4());
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null);
    String imageUrl = await storageReference.getDownloadURL();
    return imageUrl;
  }
}
