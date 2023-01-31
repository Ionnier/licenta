import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:front/screens/TaskDetailsScreen.dart';

import '../models/task_class.dart';
import '../screens/agenda/widgets/AddPlanWidget.dart';

class TaskWidget extends StatefulWidget {
  final Task task;
  final void Function()? onTicked;
  final void Function()? refreshTasks;
  const TaskWidget(
      {super.key,
      required this.task,
      required this.onTicked,
      this.refreshTasks});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  Task task = Task();

  @override
  void initState() {
    super.initState();
    setState(() {
      task = widget.task;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? checkbox;
    if (widget.onTicked != null && task.isHabit()) {
      checkbox = Checkbox(
          value: task.isDoneToday(),
          onChanged: (value) {
            widget.onTicked!();
          });
    }
    return GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TaskDetailsScreen(
                      task: task,
                    )),
          );
          if (widget.refreshTasks != null) {
            widget.refreshTasks!();
          }
        },
        child: Row(
          children: [
            if (task.priority == highPriority)
              const Icon(
                Icons.upload,
                color: Colors.red,
              )
            else if (task.priority == mediumPriority)
              const Icon(
                Icons.circle,
                color: Colors.orange,
              )
            else
              const Icon(
                Icons.download,
                color: Colors.blue,
              ),
            const SizedBox(
              width: 4.0,
            ),
            Expanded(child: Text(task.title)),
            task.isHabit()
                ? (checkbox ??
                    const SizedBox(
                      height: 0,
                    ))
                : (task.isDoable()
                    ? IconButton(
                        onPressed: () async {
                          var result = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) =>
                                  AddPlanAlertDialog(
                                    tasks: [task],
                                    initialSelected: task.localId,
                                  ));
                          if (result == true) {}
                        },
                        icon: const Icon(
                          Icons.add_chart,
                        ))
                    : AbsorbPointer(
                        child: IconButton(
                        onPressed: () => {},
                        icon: const Icon(Icons.chevron_right),
                      ))),
          ],
        ));
  }
}
