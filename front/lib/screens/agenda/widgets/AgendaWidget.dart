// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:front/data/task_local_repository.dart';
import 'package:jiffy/jiffy.dart';

import '../../../models/plan_class.dart';

class AgendaListWidget extends StatefulWidget {
  final Plan plan;
  const AgendaListWidget({super.key, required this.plan});

  @override
  State<AgendaListWidget> createState() => _AgendaListWidgetState();
}

class _AgendaListWidgetState extends State<AgendaListWidget> {
  bool isChecked = false;
  Plan plan = Plan();

  @override
  void initState() {
    plan = widget.plan;
    setState(() {
      isChecked = plan.completed;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(children: [
          Column(
            children: [
              Text(Jiffy.unixFromMillisecondsSinceEpoch(plan.startsAt).Hm),
              Text("|"),
              Text(Jiffy.unixFromMillisecondsSinceEpoch(plan.endsAt).Hm)
            ],
          ),
          SizedBox(width: 8.0),
          Expanded(
              child: Text(
            plan.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          )),
          SizedBox(width: 8.0),
          Checkbox(
              value: isChecked,
              onChanged: (value) async {
                if (value != null) {
                  widget.plan.completed = value;
                  LocalTaskDbRepository().togglePlan(widget.plan);
                  setState(() {
                    isChecked = value;
                  });
                }
              }),
        ])
      ],
    );
  }
}
