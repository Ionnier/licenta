import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:front/data/task_local_repository.dart';
import 'package:front/main.dart';
import 'package:jiffy/jiffy.dart';

import '../../models/activity_log_class.dart';

class ActivityListScreen extends StatelessWidget {
  final List<Activity> activities;
  const ActivityListScreen({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Activity log"),
        ),
        body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: activities.map((e) {
              String data = "";
              if (e.plan != null) {
                data = e.plan!.name;
              } else if (e.task != null) {
                data = e.task!.title;
              } else {
                data = e.comment ?? "";
              }
              var name = Text(
                data,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20.0),
              );
              var hey = Jiffy.unixFromMillisecondsSinceEpoch(
                  ((e.startedAt ?? (e.createdAt - e.timeSpent)) + e.timeSpent)
                      .toInt());
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(child: name),
                      Text(hey.MEd),
                      const SizedBox(
                        width: 4.0,
                      ),
                      Text(hey.Hms)
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.comment ?? "",
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      Text(Duration(milliseconds: e.timeSpent)
                          .toString()
                          .split(".")[0])
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  )
                ],
              );
            }).toList()));
  }
}
