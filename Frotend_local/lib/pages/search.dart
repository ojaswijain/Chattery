import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:social_media_app/chats/conversation.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/pages/profile.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:social_media_app/widgets/indicators.dart';
import 'package:http/http.dart' as http;

class Search extends StatefulWidget {
  final userId;
  Search({this.userId});
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  User user;
  final baseUrl = 'https://b26d-123-201-104-16.ngrok.io';
  TextEditingController searchController = TextEditingController();
  List users = [];
  List filteredUsers = [];
  bool loading = true;

  currentUserId() {
    return "123";
  }

  getUsers() async {
    var snap = await http.get(Uri.parse('$baseUrl/api/users'));
    var doc = json.decode(snap.body)["users"];
    print(doc);
    users = doc;
    filteredUsers = doc;
    setState(() {
      loading = false;
    });
  }

  search(String query) {
    filteredUsers = users;
  }

  removeFromList(index) {
    filteredUsers.removeAt(index);
  }

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildSearch(),
      ),
      body: buildUsers(),
    );
  }

  buildSearch() {
    return Row(
      children: [
        Container(
          height: 35.0,
          width: MediaQuery.of(context).size.width - 100,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
          ),
        ),
      ],
    );
  }

  buildUsers() {
    if (!loading) {
      if (filteredUsers.isEmpty) {
        return Center(
          child: Text("No User Found",
              style: TextStyle(fontWeight: FontWeight.bold)),
        );
      } else {
        return ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (BuildContext context, int index) {
            //DocumentSnapshot doc = filteredUsers[index];
            UserModel user = UserModel.fromJson(filteredUsers[index]);
            if (user.id == currentUserId()) {
              Timer(Duration(milliseconds: 500), () {
                setState(() {
                  removeFromList(index);
                });
              });
            }
            return Column(
              children: [
                ListTile(
                  onTap: () => showProfile(context, profileId: user?.id),
                  contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                  // leading: CircleAvatar(
                  //   radius: 35.0,
                  //   backgroundImage: NetworkImage(user?.photoUrl),
                  // ),
                  title: Text(user?.username,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => Conversation(
                            userId: user?.id,
                            senderId: widget.userId,
                            chatId: 'newChat',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 30.0,
                      width: 62.0,
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            'Message',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(),
              ],
            );
          },
        );
      }
    } else {
      return Center(
        child: circularProgress(context),
      );
    }
  }

  showProfile(BuildContext context, {String profileId}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => Profile(profileId: profileId),
      ),
    );
  }
}
