import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:social_media_app/auth/register/register.dart';
import 'package:social_media_app/components/stream_builder_wrapper.dart';
import 'package:social_media_app/components/stream_grid_wrapper.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/screens/edit_profile.dart';
import 'package:social_media_app/screens/settings.dart';
import 'package:social_media_app/widgets/post_tiles.dart';
import 'package:social_media_app/widgets/posts_view.dart';
import 'package:http/http.dart' as http;
class Profile extends StatefulWidget {
  final profileId;
  final userId;

  Profile({this.profileId,this.userId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User user;
  bool isLoading = false;
  int postCount = 0;
  int followersCount = 0;
  int followingCount = 0;
  bool isToggle = true;
  bool isFollowing = false;
  UserModel users;
  final DateTime timestamp = DateTime.now();
  ScrollController controller = ScrollController();
  StreamController userController =StreamController();
  StreamController postsController =StreamController();

  Future loadUser() async{
    final res= await http.get(Uri.parse('$baseUrl/api/user/'+widget.userId));
    var req=json.decode(res.body);
    userController.add(req["user"]);
    print(res);
    return req;
  }

  loadPosts() async {
    loadUser().then((res) async {
      userController.add(res);
      return res;
    });
  }

  Future<Null> _handleRefresh() async {
    loadUser().then((res) async {
      print(res.toString());
      userController.add(res);
      return null;
    });

    loadMyPosts().then((res) async {
      print(res.toString());
      postsController.add(res);
      return null;
    });
  }

  Future loadMyPosts() async{
    final res= await http.get(Uri.parse('$baseUrl/api/feed?user_id'+widget.profileId+'&type=get'));
    var req=json.decode(res.body);
    postsController.add(req["details"]);
    print(res);
    return req;
  }

  loadPostsMy() async {
    loadMyPosts().then((res) async {
      postsController.add(res);
      return res;
    });
  }


  @override
  void initState() {
    super.initState();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    print(widget.profileId);
    final response = await http.get(Uri.parse('$baseUrl/api/user/'+widget.profileId));
    var req=json.decode(response.body);
    var res=req["user"]["friends"];

    setState(() {
      isFollowing = res.contains(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('WOOBLE'),
        actions: [
          widget.profileId == widget.userId
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 25.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                            CupertinoPageRoute(builder: (_) => Register()));
                      },
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 15.0),
                      ),
                    ),
                  ),
                )
              : SizedBox()
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            floating: false,
            toolbarHeight: 5.0,
            collapsedHeight: 6.0,
            expandedHeight: 220.0,
            flexibleSpace: FlexibleSpaceBar(
              background: StreamBuilder(
                stream: userController.stream,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    var doc= snapshot.data;
                    _handleRefresh();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: CircleAvatar(
<<<<<<< HEAD
                                backgroundImage: MemoryImage(base64Decode(doc["profile_picture"])),
=======
                                backgroundImage: MemoryImage(
                                    base64Decode(user?.profilePicture)),
>>>>>>> 853e4f140bcf10bf8b8285893b84af300895d442
                                radius: 40.0,
                              ),
                            ),
                            SizedBox(width: 20.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 32.0),
                                Row(
                                  children: [
                                    Visibility(
                                      visible: false,
                                      child: SizedBox(width: 10.0),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 130.0,
                                          child: Text(
                                            doc["username"],
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w900),
                                            maxLines: null,
                                          ),
                                        ),
                                        SizedBox(width: 10.0),
                                      ],
                                    ),
                                    widget.profileId == widget.userId
                                        ? InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                CupertinoPageRoute(
                                                  builder: (_) => Setting(),
                                                ),
                                              );
                                            },
                                            child: Column(
                                              children: [
                                                Icon(Feather.settings,
                                                    color: Theme.of(context)
                                                        .accentColor),
                                                Text(
                                                  'settings',
                                                  style:
                                                      TextStyle(fontSize: 11.5),
                                                )
                                              ],
                                            ),
                                          )
                                        :Center() //buildLikeButton()
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                          child: doc["bio"].isEmpty
                              ? Container()
                              : Container(
                                  width: 200,
                                  child: Text(
                                    doc["bio"],
                                    style: TextStyle(
                                      //    color: Color(0xff4D4D4D),
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: null,
                                  ),
                                ),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          height: 50.0,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                StreamBuilder(
                                  stream: postsController.stream,
                                  builder: (context,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.hasData) {
                                      var docs = snapshot.data;
                                      return buildCount(
                                          "POSTS", docs?.length ?? 0);
                                    } else {
                                      return buildCount("POSTS", 0);
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Container(
                                    height: 50.0,
                                    width: 0.3,
                                    color: Colors.grey,
                                  ),
                                ),
                                StreamBuilder(
                                  stream: userController.stream,
                                  builder: (context,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.hasData) {
                                      var snap = snapshot.data;
                                      return buildCount(
                                          "FRIENDS", snap["friends"]?.length ?? 0);
                                    } else {
                                      return buildCount("FRIENDS", 0);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        buildProfileButton(user),
                      ],
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index > 0) return null;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Text(
                            'All Posts',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Spacer(),
                          buildIcons(),
                        ],
                      ),
                    ),
                    buildPostView()
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

//show the toggling icons "grid" or "list" view.
  buildIcons() {
    if (isToggle) {
      return IconButton(
          icon: Icon(Feather.list),
          onPressed: () {
            setState(() {
              isToggle = false;
            });
          });
    } else if (isToggle == false) {
      return IconButton(
        icon: Icon(Icons.grid_on),
        onPressed: () {
          setState(() {
            isToggle = true;
          });
        },
      );
    }
  }

  buildCount(String label, int count) {
    return Column(
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w900,
              fontFamily: 'Ubuntu-Regular'),
        ),
        SizedBox(height: 3.0),
        Text(
          label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              fontFamily: 'Ubuntu-Regular'),
        )
      ],
    );
  }

  buildProfileButton(user) {
    //if isMe then display "edit profile"
    bool isMe = widget.profileId == widget.userId;
    if (isMe) {
      return buildButton(
          text: "Edit Profile",
          function: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => EditProfile(
                  user: user,
                ),
              ),
            );
          });
      //if you are already following the user then "unfollow"
    } else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnfollow,
      );
      //if you are not following the user then "follow"
    } else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        function: handleFollow,
      );
    }
  }

  buildButton({String text, Function function}) {
    return Center(
      child: GestureDetector(
        onTap: function,
        child: Container(
          height: 40.0,
          width: 200.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).accentColor,
                Color(0xff597FDB),
              ],
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  handleUnfollow() async {
    final res= await http.post(Uri.parse('$baseUrl/api/edit'),body:{
      "user_id" : widget.userId,
      "delete_friend": widget.profileId
    });
    setState(() {
      isFollowing = false;
    });
  }

  handleFollow() async {
    final res= await http.post(Uri.parse('$baseUrl/api/edit'),body:{
      "user_id" : widget.userId,
      "add_friend": widget.profileId
    });
    setState(() {
      isFollowing = true;
    });
    //updates the followers collection of the followed user
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .set({});
    //updates the following collection of the currentUser
    followingRef
        .doc(currentUserId())
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    //update the notification feeds
    notificationRef
        .doc(widget.profileId)
        .collection('notifications')
        .doc(currentUserId())
        .set({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": users.username,
      "userId": users.id,
      "userDp": users.profilePicture,
      "timestamp": timestamp,
    });
  }

  buildPostView() {
    if (isToggle == true) {
      return buildGridPost();
    } else if (isToggle == false) {
      return buildPosts();
    }
  }

  buildPosts() {
    return StreamBuilderWrapper(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      stream: postsController.stream,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, var snapshot) {
        PostModel posts = PostModel.fromJson(snapshot.data());
        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Posts(
            post: posts,
          ),
        );
      },
    );
  }

  buildGridPost() {
    return StreamGridWrapper(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      stream: postRef
          .where('ownerId', isEqualTo: widget.profileId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, DocumentSnapshot snapshot) {
        PostModel posts = PostModel.fromJson(snapshot.data());
        return PostTile(
          post: posts,
        );
      },
    );
  }

  // buildLikeButton() {
  //   return StreamBuilder(
  //     stream: favUsersRef
  //         .where('postId', isEqualTo: widget.profileId)
  //         .where('userId', isEqualTo: currentUserId())
  //         .snapshots(),
  //     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //       if (snapshot.hasData) {
  //         List<QueryDocumentSnapshot> docs = snapshot?.data?.docs ?? [];
  //         return GestureDetector(
  //           onTap: () {
  //             if (docs.isEmpty) {
  //               favUsersRef.add({
  //                 'userId': currentUserId(),
  //                 'postId': widget.profileId,
  //                 'dateCreated': Timestamp.now(),
  //               });
  //             } else {
  //               favUsersRef.doc(docs[0].id).delete();
  //             }
  //           },
  //           child: Container(
  //             decoration: BoxDecoration(boxShadow: [
  //               BoxShadow(
  //                 color: Colors.grey.withOpacity(0.2),
  //                 spreadRadius: 3.0,
  //                 blurRadius: 5.0,
  //               )
  //             ], color: Colors.white, shape: BoxShape.circle),
  //             child: Padding(
  //               padding: EdgeInsets.all(3.0),
  //               child: Icon(
  //                 docs.isEmpty
  //                     ? CupertinoIcons.heart
  //                     : CupertinoIcons.heart_fill,
  //                 color: Colors.red,
  //               ),
  //             ),
  //           ),
  //         );
  //       }
  //       return Container();
  //     },
  // );
  //}
}
