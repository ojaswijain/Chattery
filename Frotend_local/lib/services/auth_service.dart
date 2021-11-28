import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:http/http.dart' as http;
class AuthService {
  final baseUrl = 'https://b26d-123-201-104-16.ngrok.io';
  String message="";
  String userId;
  User getCurrentUser() {
    User user = firebaseAuth.currentUser;
    return user;
  }

//create a firebase user 
  Future<bool> createUser(
      {String name,
      User user,
      String email,
      String country,
      String password}) async {
    try {
      var res = await http.post(Uri.parse('$baseUrl/api/auth'), body: {
        'username': name,
        'password': password,
        'first_name': "kkk",
        'last_name':"ll",
        'gender':"ll",
        "type":"register"
      });
      var succ=json.decode(res.body);
      print(succ);
      if (succ["success"]) {
        final req=succ["details"];
        print(req);
        userId=req["_id"];
        return true;
      } else {
        message=succ["message"];
        return false;
      }
    } finally {
      print("regsitered");
    }

  }

//function to login a user with his email and password
  Future<bool> loginUser({String username, String password}) async {
    try {
      var res = await http.post(
          Uri.parse('$baseUrl/api/auth'),
        body: {
          'username': username,
          'password': password,
          'type':'login'
        },
      );
      final succ=json.decode(res.body);
      print(succ);
      if (succ["success"]) {
        final req=succ["details"];
        print(req);
        userId=req["_id"];
        return true;
      } else {
        message=succ["message"];
        return false;
      }
    } finally {
      print("logged in");
      // you can do somethig here
    }
  }

  forgotPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  logOut() async {
    await firebaseAuth.signOut();
  }
}
