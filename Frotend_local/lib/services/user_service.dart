import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/services/services.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService extends Service {
  final baseUrl = 'https://57f8-123-201-104-16.ngrok.io';

  //get the authenticated uis
  String currentUid() {
    return firebaseAuth.currentUser.uid;
  }

//updates user profile in the Edit Profile Screen
  updateProfile({File image, String bio, String userId}) async {
    DocumentSnapshot doc = await usersRef.doc(currentUid()).get();
    var users = UserModel.fromJson(doc.data());
    users?.bio = bio;
    final bytes = await image.readAsBytes();
    String url = base64.encode(bytes);
    await http.post(Uri.parse('$baseUrl/api/edit'), body: {
      "user_id": userId,
      "profile_picture": url,
    });

    // await usersRef.doc(currentUid()).update({
    //   'username': username,
    //   'bio': bio,
    //   "profilePicture": users?.profilePicture ?? '',
    // });

    return true;
  }
}
