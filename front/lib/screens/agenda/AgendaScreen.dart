import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:front/data/task_local_repository.dart';
import 'package:front/main.dart';
import 'package:front/screens/agenda/widgets/AgendaWidget.dart';
import 'package:jiffy/jiffy.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/auth_repository.dart';
import '../../models/plan_class.dart';

class AgendaScreen extends StatefulWidget {
  final List<Plan> plans;
  final Function? update;
  const AgendaScreen({super.key, required this.plans, this.update});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  @override
  void initState() {
    if (widget.update != null) {
      widget.update!();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Container? secondaryBackground;
    String? data;
    if (Platform.isAndroid || Platform.isIOS) {
      secondaryBackground = Container(
          color: Colors.blue,
          child: Row(
            children: const [
              Spacer(),
              Text("Add to calendar"),
              SizedBox(
                width: 8.0,
              ),
              Icon(Icons.calendar_month),
              SizedBox(
                width: 8.0,
              ),
            ],
          ));
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Jiffy().MMMd,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 24.0),
            ),
            if (AuthRepository().isLoggedIn())
              IconButton(
                  onPressed: () async {
                    if (data == null) {
                      var response = await Dio(BaseOptions(headers: {
                        "Authorization": "Bearer ${AuthRepository().getKey()}"
                      })).get("$domainURL/storage/icalself");
                      if (response.statusCode == 200) {
                        data = "$domainURL${response.data["data"]}";
                      }
                    }
                    if (data != null) {
                      Share.share(data!);
                    }
                  },
                  icon: const Icon(Icons.share)),
          ],
        ),
        const SizedBox(height: 4.0),
        for (var plan in widget.plans)
          Dismissible(
            background: Container(
              color: Colors.red,
              child: Row(children: const [
                Icon(Icons.delete),
                SizedBox(
                  width: 8.0,
                ),
                Text("Delete"),
              ]),
            ),
            secondaryBackground: secondaryBackground,
            key: Key(plan.localId.toString()),
            child: AgendaListWidget(plan: plan),
            confirmDismiss: (direction) async {
              if ((Platform.isAndroid || Platform.isIOS) &&
                  direction == DismissDirection.endToStart) {
                final Event event = Event(
                  title: plan.name,
                  description: plan.name,
                  startDate: plan.startsAt.fromEpoch(),
                  endDate: plan.endsAt.fromEpoch(),
                );
                await Add2Calendar.addEvent2Cal(event);
                return false;
              }
              final bool res = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Text("Delete ${plan.name}?"),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            "Cancel",
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        FilledButton(
                          child: const Text(
                            "Delete",
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  });
              if (res) {
                // Remove the item from the data source.
                await LocalTaskDbRepository().deletePlan(plan);
                if (widget.update != null) {
                  widget.update!();
                  widget.plans.remove(plan);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Plan deleted")));
                  }
                }
                return true;
              }
              return false;
            },
          )
      ],
    );
  }
}
