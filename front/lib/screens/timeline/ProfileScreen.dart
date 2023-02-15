import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:front/data/auth_repository.dart';
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

  Data();

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json['userName'];
    userEmail = json['userEmail'];
    userPassword = json['userPassword'];
    createdDate = json['createdDate'];
    updatedDate = json['updatedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userName'] = this.userName;
    data['userEmail'] = this.userEmail;
    data['userPassword'] = this.userPassword;
    data['createdDate'] = this.createdDate;
    data['updatedDate'] = this.updatedDate;
    return data;
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  Data data = Data();

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
      })).get("$domainURL/api/self");
    } else {
      response = await Dio().get("$domainURL/api/users/${widget.userId}");
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> list = response.data["data"];
      setState(() {
        data = Data.fromJson(list);
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
      appBar: AppBar(),
      body: Column(children: [
        Row(children: [
          const Icon(Icons.account_box),
          Center(
            child: Text(data.userName),
          )
        ]),
        Row(children: [
          const Icon(Icons.email),
          Center(
            child: Text(data.userEmail),
          )
        ]),
        Row(children: [
          const Icon(Icons.calendar_month),
          Center(
            child: Text(Jiffy(data.createdDate.fromUnix()).yMMMMEEEEd),
          )
        ]),
        Row(children: [
          const Icon(Icons.code),
          Center(
            child: SelectableText(data.id),
          )
        ]),
      ]),
    );
  }
}
