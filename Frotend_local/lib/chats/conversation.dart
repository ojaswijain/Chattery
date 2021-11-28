import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/components/chat_bubble.dart';
import 'package:social_media_app/models/enum/message_type.dart';
import 'package:social_media_app/models/message.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:social_media_app/view_models/conversation/conversation_view_model.dart';
import 'package:social_media_app/view_models/user/user_view_model.dart';
import 'package:social_media_app/widgets/indicators.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;
class Conversation extends StatefulWidget {
  final String userId;
  final String chatId;
  final String senderId;
  const Conversation({@required this.userId,@required this.senderId, @required this.chatId});

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  FocusNode focusNode = FocusNode();
  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();
  bool isFirst = false;
  String chatId;
  StreamController _messagesController;
  StreamController _userController;
  final baseUrl='https://b26d-123-201-104-16.ngrok.io';

  Future fetchPost() async {
    print(widget.senderId);
      final response = await http.get(Uri.parse('$baseUrl/api/chat?id1='+widget.senderId+'&id2='+widget.userId));
      var req=json.decode(response.body);
      print(req["message"]);
      return req["message"];
  }

  Future loadUser() async{
    final res= await http.get(Uri.parse('$baseUrl/api/user/'+widget.userId));
    var req=json.decode(res.body);
    _userController.add(req["user"]);
    print(res);
    return req;
  }
  loadPosts() async {
    fetchPost().then((res) async {
      _messagesController.add(res);
      return res;
    });
  }

  Future<Null> _handleRefresh() async {
    fetchPost().then((res) async {
      print(res.toString());
      _messagesController.add(res);
      return null;
    });
  }

  @override
  void initState() {
    _messagesController = new StreamController();
    _userController = new StreamController();

    super.initState();
    scrollController.addListener(() {
      focusNode.unfocus();
    });
    if (widget.chatId == 'newChat') {
      isFirst = true;
    }
    chatId = widget.chatId;
    loadPosts();
    loadUser();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ConversationViewModel>(
        builder: (BuildContext context, viewModel, Widget child) {
      return Scaffold(
        key: viewModel.scaffoldKey,
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.keyboard_backspace,
            ),
          ),
          elevation: 0.0,
          titleSpacing: 0,
          title: buildUserName(),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Flexible(
                child: StreamBuilder(
                  stream: _messagesController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List messages = snapshot.data;
                      print(messages.toString());
                      _handleRefresh();
                      print("ppp");
                      return ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        itemCount: messages.length,
                        reverse: true,
                        itemBuilder: (BuildContext context, int index) {
                          Message message = Message.fromJson(
                              messages.reversed.toList()[index]);
                          return ChatBubble(
                              message: '${message.content}',
                              //time: message?.time,
                              isMe: message?.senderUid == widget.senderId,
                              type: message?.type
                          );
                        },
                      );
                    } else {
                      return Center(child: circularProgress(context));
                    }
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: BottomAppBar(
                  elevation: 10.0,
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 100.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.photo_on_rectangle,
                            color: Theme.of(context).accentColor,
                          ),
                          onPressed: () => showPhotoOptions(viewModel, widget.userId),
                        ),
                        Flexible(
                          child: TextField(
                            controller: messageController,
                            focusNode: focusNode,
                            style: TextStyle(
                              fontSize: 15.0,
                              color:
                                  Theme.of(context).textTheme.headline6.color,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10.0),
                              enabledBorder: InputBorder.none,
                              border: InputBorder.none,
                              hintText: "Type your message",
                              hintStyle: TextStyle(
                                color:
                                    Theme.of(context).textTheme.headline6.color,
                              ),
                            ),
                            maxLines: null,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Feather.send,
                            color: Theme.of(context).accentColor,
                          ),
                          onPressed: () {
                            if (messageController.text.isNotEmpty) {
                              sendMessage(viewModel, widget.senderId);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  buildUserName() {
    return StreamBuilder(
      stream: _userController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var user = snapshot.data;
          return InkWell(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Hero(
                    tag:user["first_name"],
                    child: CircleAvatar(
                      radius: 25.0,
                      // backgroundImage: CachedNetworkImageProvider(
                      //   '${user.photoUrl}',
                      // ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${user["username"]}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                      ),
                      SizedBox(height: 5.0),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {},
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  showPhotoOptions(ConversationViewModel viewModel, var user) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text("Camera"),
              onTap: () {
                sendMessage(viewModel, widget.senderId, imageType: 0, isImage: true);
              },
            ),
            ListTile(
              title: Text("Gallery"),
              onTap: () {
                sendMessage(viewModel, widget.senderId, imageType: 1, isImage: true);
              },
            ),
          ],
        );
      },
    );
  }

  sendMessage(ConversationViewModel viewModel, var user,
      {bool isImage = false, int imageType}) async {
    String msg;
    if (isImage) {
      msg = await viewModel.pickImage(
        source: imageType,
        context: context,
        chatId: chatId,
      );
    } else {
      msg = messageController.text.trim();
      messageController.clear();
    }

    Message message = Message(
      content: '$msg',
      senderUid: user,
      type: isImage ? MessageType.IMAGE : MessageType.TEXT,
      time: "",
    );

    if (msg.isNotEmpty) {
        viewModel.sendMessage(
          widget.userId,
          message,
        );
    }
  }
}
