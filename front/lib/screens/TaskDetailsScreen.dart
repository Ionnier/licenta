import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:front/data/task_local_repository.dart';
import 'package:front/widgets/ActivityWidget.dart';
import 'package:front/widgets/MainTaskWidget.dart';

import '../models/activity_log_class.dart';
import '../models/task_class.dart';
import 'InputTask.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task task;
  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  Task task = Task();

  @override
  void initState() {
    task = widget.task;
    updateTask();
    super.initState();
  }

  void updateTask() {
    setState(() {
      LocalTaskDbRepository().getActivities(task).then((value) {
        task.activities = value;
        var copy = task;
        task = Task();
        task = copy;
        task.title = "sdsd";
        print("DONE");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.parentId == null ? "Details" : "Subtask"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView(
          children: [
            const SizedBox(
              height: 4.0,
            ),
            Text(
              task.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 4.0,
            ),
            Text(
              task.description,
              textAlign: TextAlign.justify,
            ),
            Row(
              children: [
                Expanded(
                    child: FilledButton(
                        onPressed: () async {
                          final _formKey = GlobalKey<FormState>();
                          final commentController = TextEditingController();
                          final timeSpentController = TextEditingController();
                          final Activity activity = Activity();
                          var result = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Add work'),
                              content: Form(
                                  key: _formKey,
                                  child: ListView(children: [
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Comment',
                                      ),
                                      controller: commentController,
                                    ),
                                    const SizedBox(
                                      height: 4.0,
                                    ),
                                    TextFormField(
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Time spent',
                                        ),
                                        validator: (value) {
                                          if (value == null) {
                                            return "Can't be empty";
                                          }
                                          var parse = int.tryParse(value);
                                          if (parse == null || parse == 0) {
                                            return "Can't be non number";
                                          }
                                        },
                                        readOnly: true,
                                        controller: timeSpentController,
                                        onTap: () {
                                          var date = DateTime.now();
                                          DatePicker.showTimePicker(context,
                                              showTitleActions: true,
                                              currentTime: DateTime(date.year,
                                                      date.month, date.day)
                                                  .add(Duration(
                                                      milliseconds: int.tryParse(
                                                              timeSpentController
                                                                  .text) ??
                                                          0)),
                                              onConfirm: (date) {
                                            timeSpentController.text = date
                                                .difference(DateTime(date.year,
                                                    date.month, date.day))
                                                .inMilliseconds
                                                .toString();
                                          });
                                        }),
                                    const SizedBox(
                                      height: 4.0,
                                    ),
                                  ])),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    } else {
                                      if (commentController.text.isNotEmpty) {
                                        activity.comment =
                                            commentController.text;
                                      }
                                      activity.timeSpent = int.tryParse(
                                          timeSpentController.text)!;
                                      activity.parentId = task.localId;
                                      Navigator.pop(context, true);
                                    }
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          if (result == true) {
                            await LocalTaskDbRepository()
                                .insertActivity(activity);
                            updateTask();
                          }
                        },
                        child: const Text("Add work"))),
                Expanded(
                    child: FilledButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => InputTaskScreen(
                                      activityType: task.isHabit()
                                          ? habitType
                                          : activityType,
                                      task: task,
                                    )),
                          );
                        },
                        child: const Text("Edit"))),
                const SizedBox(
                  width: 8.0,
                ),
                Expanded(
                    child: FilledButton(
                        onPressed: () async {
                          var result = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Delete task'),
                              content: const Text(
                                  'Are you sure you want to delete this task?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          if (result == true) {
                            await LocalTaskDbRepository().deleteTask(task);
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                        child: const Text("Delete"))),
                const SizedBox(
                  width: 8.0,
                ),
                if (!task.isHabit() && task.parentId == null)
                  Expanded(
                      child: FilledButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InputTaskScreen(
                                        activityType: activityType,
                                        parentId: task.localId,
                                      )),
                            );
                          },
                          child: const Text("Add subtask"))),
              ],
            ),
            const SizedBox(
              height: 4.0,
            ),
            if (task.subTasks != null && task.subTasks!.isNotEmpty)
              const Text(
                "Subtasks",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            if (task.subTasks != null)
              for (var subtask in task.subTasks!)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TaskWidget(
                    task: subtask,
                    onTicked: null,
                  ),
                ),
            if (task.activities != null && task.activities!.isNotEmpty)
              const Text(
                "History",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            if (task.activities != null)
              for (var act in task.activities!)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ActivityWidget(
                    activity: act,
                  ),
                )
          ],
        ),
      ),
    );
  }
}
