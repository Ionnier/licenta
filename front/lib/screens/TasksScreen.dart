import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:front/data/task_local_repository.dart';
import 'package:front/widgets/MainTaskWidget.dart';

import '../models/task_class.dart';

class TasksScreen extends StatefulWidget {
  List<Task>? tasks = List.empty();
  TasksScreen({super.key, this.tasks});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> tasks = List.empty();
  bool isLoading = false;

  bool showCompleted = false;
  bool hideHabits = false;
  bool hideActivities = false;

  @override
  void initState() {
    super.initState();
    updateTasks(firstTime: true);
  }

  void updateTasks({bool firstTime = false}) {
    if (firstTime && widget.tasks != null) {
      setState(() {
        tasks = widget.tasks!;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });
    LocalTaskDbRepository().getTasks().then((value) {
      setState(() {
        tasks = value;
        isLoading = false;
      });
    }).onError((error, stackTrace) {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (tasks.isEmpty) {
      return const Center(child: Text("No tasks."));
    }
    List<Widget> children = List.empty(growable: true);
    children.add(SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          InputChip(
            label: const Text('Show completed'),
            selected: showCompleted,
            onSelected: (value) {
              setState(() {
                showCompleted = value;
              });
            },
          ),
          InputChip(
            label: const Text('Hide activities'),
            selected: hideActivities,
            onSelected: (value) {
              setState(() {
                hideActivities = value;
              });
            },
          ),
          InputChip(
            label: const Text('Hide habits'),
            selected: hideHabits,
            onSelected: (value) {
              setState(() {
                hideHabits = value;
              });
            },
          )
        ])));
    children.addAll(tasks
        .where((element) {
          if (hideHabits && element.isHabit()) {
            return false;
          }
          return true;
        })
        .where((element) {
          if (element.isDoneToday() && !showCompleted) {
            return false;
          }
          return true;
        })
        .map(
          (e) => TaskWidget(
            onTicked: () async {
              if (!e.isDoneToday()) {
                await LocalTaskDbRepository().markAsCompleted(e);
              } else {
                await LocalTaskDbRepository().deleteCompletion(e);
              }
              updateTasks();
            },
            refreshTasks: () => {updateTasks()},
            task: e,
          ),
        )
        .toList());
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: children,
    );
  }
}
