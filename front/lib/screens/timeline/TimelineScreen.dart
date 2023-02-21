import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:front/data/timeline_repository.dart';
import 'package:front/main.dart';
import 'package:front/screens/timeline/ProfileScreen.dart';
import 'package:front/screens/timeline/TimelineListElement.dart';
import 'package:jiffy/jiffy.dart';

import '../../data/auth_repository.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class TimeLineElement {
  String userId = "";
  String name = "";
  String email = "";
  String comment = "";
  String imageUrl = "";
  int startsAt = 0;
  int endsAt = 0;

  static TimeLineElement fromJson(json) {
    TimeLineElement p = TimeLineElement();
    p.userId = json["id"] ?? "";
    p.comment = json["comment"];
    p.startsAt = json["startsAt"];
    p.endsAt = json["endsAt"];
    p.name = json["name"] ?? "";
    p.email = json["email"] ?? "";
    p.imageUrl = json["imageUrl"] ?? "";
    return p;
  }
}

class _TimelineScreenState extends State<TimelineScreen> {
  bool isLoading = false;
  List<TimeLineElement> elements = List.empty();

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    var response = await Dio(BaseOptions(
      headers: {"Authorization": "Bearer ${AuthRepository().getKey()}"},
      receiveDataWhenStatusError: true,
    )).get("$domainURL/timeline/");
    if (response.statusCode == 200) {
      List<dynamic> list = response.data["data"];
      List<TimeLineElement> itemsList =
          List<TimeLineElement>.from(list.map<TimeLineElement>((dynamic i) {
        return TimeLineElement.fromJson(i);
      }));
      setState(() {
        elements = itemsList;
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
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          children: [
            const Spacer(),
            InkWell(
              child: const Icon(Icons.add),
              onTap: () async {
                final result = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      TextEditingController asd = TextEditingController();

                      return AlertDialog(
                          title: const Text("Insert friend code"),
                          content: TextFormField(
                            controller: asd,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Insert data";
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          actions: [
                            TextButton(
                                onPressed: () async {
                                  if (asd.text.isNotEmpty) {
                                    var result = await TimelineRepository()
                                        .followUser(asd.text);
                                    if (result && context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text("User followed.")));
                                      Navigator.pop(context, true);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text("There was an eror.")));
                                    }
                                  }
                                },
                                child: const Text("Confirm"))
                          ]);
                    });
              },
            ),
            const SizedBox(
              width: 8.0,
            )
          ],
        ),
        for (var element in elements)
          TimelineElement(
            onProfileClick: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(userId: element.userId)),
              );
            },
            imageUrl: element.imageUrl,
            name: element.name,
            comment: element.comment,
            startsAt: Jiffy(element.startsAt.fromEpoch()).yMMMMEEEEdjm,
            duration:
                Jiffy((element.endsAt - element.startsAt).fromEpoch()).Hms,
          ),
      ],
    );
  }
}
