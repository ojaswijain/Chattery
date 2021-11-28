import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/services/services.dart';
import 'package:social_media_app/utils/firebase.dart';

class UserService extends Service {
  
  //get the authenticated uis
  String currentUid() {
    return firebaseAuth.currentUser.uid;
  }

//tells when the user is online or not and updates the last seen for the messages
  setUserStatus(bool isOnline) {
    var user = firebaseAuth.currentUser;
    if (user != null) {
      usersRef
          .doc(user.uid)
          .update({'isOnline': isOnline, 'lastSeen': Timestamp.now()});
    }
  }


//updates user profile in the Edit Profile Screen
  updateProfile(
      {File image, String username, String bio, String gender}) async {
    DocumentSnapshot doc = await usersRef.doc(currentUid()).get();
    var users = UserModel.fromJson(doc.data());
    users?.username = username;
    users?.bio = bio;
    users?.gender = gender;
    if (image != null) {
      users?.photoUrl = await uploadImage(profilePic, image);
    }
    await usersRef.doc(currentUid()).update({
      'username': username,
      'bio': bio,
      'gender': gender,
      "photoUrl": users?.photoUrl ?? '',
    });

    return true;
  }
}
