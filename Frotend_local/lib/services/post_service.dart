import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/screens/view_image.dart';
import 'package:social_media_app/services/services.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class PostService extends Service {
  String postId = Uuid().v4();
  final baseUrl = 'https://57f8-123-201-104-16.ngrok.io';
//uploads profile picture to the users collection
  uploadProfilePicture(File image, String userId) async {
    final bytes = await image.readAsBytes();
    String url = base64.encode(bytes);
    await http.post(Uri.parse('$baseUrl/api/edit'), body: {
      "user_id": userId,
      "profile_picture": url,
    });
  }

//uploads post to the post collection
  uploadPost(File image, String userId, String description) async {
    final bytes = await image.readAsBytes();
    String url = base64.encode(bytes);
    await http.post(Uri.parse('$baseUrl/api/feed'), body: {
      "user_id": userId,
      "content": url,
      "description": description,
    });
  }

//upload a comment
  uploadComment(String currentUserId, String comment, String postId,
      String ownerId, String mediaUrl) async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId).get();
    user = UserModel.fromJson(doc.data());
    await commentRef.doc(postId).collection("comments").add({
      "username": user.username,
      "comment": comment,
      "timestamp": Timestamp.now(),
      "userDp": user.profilePicture,
      "userId": user.id,
    });
    bool isNotMe = ownerId != currentUserId;
    if (isNotMe) {
      addCommentToNotification("comment", comment, user.username, user.id,
          postId, mediaUrl, ownerId, user.photoUrl);
    }
  }

//add the comment to notification collection
  addCommentToNotification(
      String type,
      String commentData,
      String username,
      String userId,
      String postId,
      String mediaUrl,
      String ownerId,
      String userDp) async {
    await notificationRef.doc(ownerId).collection('notifications').add({
      "type": type,
      "commentData": commentData,
      "username": username,
      "userId": userId,
      "userDp": userDp,
      "postId": postId,
      "mediaUrl": mediaUrl,
      "timestamp": Timestamp.now(),
    });
  }

//add the likes to the notfication collection
  addLikesToNotification(String type, String username, String userId,
      String postId, String mediaUrl, String ownerId, String userDp) async {
    await notificationRef
        .doc(ownerId)
        .collection('notifications')
        .doc(postId)
        .set({
      "type": type,
      "username": username,
      "userId": firebaseAuth.currentUser.uid,
      "userDp": userDp,
      "postId": postId,
      "mediaUrl": mediaUrl,
      "timestamp": Timestamp.now(),
    });
  }
}
