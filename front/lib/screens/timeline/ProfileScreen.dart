import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:front/data/auth_repository.dart';
import 'package:front/screens/timeline/TimelineListElement.dart';
import 'package:front/screens/timeline/TimelineScreen.dart';
import 'package:jiffy/jiffy.dart';

import '../../main.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class Data {
  String id = "";
  String userName = "";
  String userEmail = "";
  String userPassword = "";
  int createdDate = 0;
  int updatedDate = 0;
  String imageUrl = "";

  Data();

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json['userName'];
    userEmail = json['userEmail'];
    userPassword = json['userPassword'];
    createdDate = json['createdDate'];
    updatedDate = json['updatedDate'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userName'] = this.userName;
    data['userEmail'] = this.userEmail;
    data['userPassword'] = this.userPassword;
    data['createdDate'] = this.createdDate;
    data['updatedDate'] = this.updatedDate;
    data['imageUrl'] = this.imageUrl;
    return data;
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  Data data = Data();
  List<Data> friendList = List.empty();
  List<TimeLineElement> posts = List.empty();

  @override
  void initState() {
    super.initState();
    startLoading();
  }

  void startLoading() async {
    setState(() {
      isLoading = true;
    });
    Response<dynamic> response;
    if (widget.userId == null) {
      response = await Dio(BaseOptions(headers: {
        "Authorization": "Bearer ${AuthRepository().getKey()}"
      })).get("$domainURL/profile/self");
    } else {
      response = await Dio().get("$domainURL/profile/${widget.userId}");
    }

    if (response.statusCode == 200) {
      print(response.data);
      Map<String, dynamic> list = response.data["owner"];
      List<dynamic> friends = response.data["profiles"];
      List<dynamic> timeline = response.data["timeline"];
      setState(() {
        data = Data.fromJson(list);
        friendList = friends.map((e) => Data.fromJson(e)).toList();
        posts = timeline.map((e) => TimeLineElement.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Column(children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              const Icon(Icons.calendar_month),
              Center(
                child: Text(Jiffy(data.createdDate.fromUnix()).yMMMMEEEEd),
              )
            ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          CachedNetworkImage(
            width: 64,
            height: 64,
            placeholder: (context, url) => const CircularProgressIndicator(),
            imageUrl: data.imageUrl.isNotEmpty
                ? data.imageUrl
                : "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fclipground.com%2Fimages%2Fdefault-image-icon-png-4.png&f=1&nofb=1&ipt=6c40744f021c9dcc880eb432f338d9fff778d199dc615dacd3de4ab1ae19f345&ipo=images",
            errorWidget: (context, string, error) => const Icon(Icons.error),
          ),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (data.userName.isNotEmpty) const Icon(Icons.account_box),
          if (data.userName.isNotEmpty) Text(data.userName),
          if (data.userEmail.isNotEmpty) const Icon(Icons.email),
          if (data.userEmail.isNotEmpty) Text(data.userEmail),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.code),
          Center(
            child: SelectableText(data.id),
          )
        ]),
        if (friendList.isNotEmpty) Row(children: const [Text("Friend list")]),
        Row(
          children: [
            for (var i = 0; i < min(friendList.length, 3); i++)
              InkWell(
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                              userId: friendList[i].id,
                            )),
                  )
                },
                child: Column(
                  children: [
                    CachedNetworkImage(
                      width: 64,
                      height: 64,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      imageUrl: friendList[i].imageUrl.isNotEmpty
                          ? friendList[i].imageUrl
                          : "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fclipground.com%2Fimages%2Fdefault-image-icon-png-4.png&f=1&nofb=1&ipt=6c40744f021c9dcc880eb432f338d9fff778d199dc615dacd3de4ab1ae19f345&ipo=images",
                      errorWidget: (context, string, error) =>
                          const Icon(Icons.error),
                    ),
                    Text(friendList[i].userName)
                  ],
                ),
              )
          ],
        ),
        if (posts.isNotEmpty) Row(children: const [Text("Timeline:")]),
        Wrap(
          spacing: 8,
          children: [
            for (var post in posts)
              TimelineElement(
                onProfileClick: null,
                name: null,
                comment: post.comment,
                startsAt: Jiffy(post.startsAt.fromEpoch()).yMMMMEEEEdjm,
                duration: Jiffy((post.endsAt).fromEpoch()).Hms,
                imageUrl: null,
              )
          ],
        )
      ]),
    );
  }
}
