import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:front/data/task_local_repository.dart';
import 'package:front/db/db.dart';
import 'package:front/screens/AddTask.dart';
import 'package:front/screens/TasksScreen.dart';
import 'package:front/screens/activity/ActivityListScreen.dart';
import 'package:front/screens/agenda/AgendaScreen.dart';
import 'package:front/screens/agenda/widgets/AddPlanWidget.dart';

import '../models/plan_class.dart';
import '../models/task_class.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int selectedIndex = 0;
  List<Plan> plans = List.empty();
  List<Task>? tasks;

  @override
  void initState() {
    _updatePlans();
    _updateTasks();
    super.initState();
  }

  void _updatePlans() {
    LocalTaskDbRepository().getPlans().then((value) {
      setState(() {
        plans = List.empty();
        plans = value;
      });
    });
  }

  void _updateTasks() {
    LocalTaskDbRepository().getTasks().then((value) {
      setState(() {
        tasks = value;
      });
    });
  }

  final List<String> choices = ["Activity Log", "Toggle random color"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'assets/logo.svg',
            width: 16.0,
            height: 16.0,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        actions: [
          PopupMenuButton(
              onSelected: (value) {
                switch (choices.indexOf(value)) {
                  case 0:
                    {
                      LocalTaskDbRepository().getOnlyActivities().then((value) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ActivityListScreen(activities: value),
                            ));
                      });
                      break;
                    }
                  case 1:
                    {
                      final currentValue = AppDb().getRandomColor();
                      AppDb().setRandomColor(!currentValue).then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(currentValue == true
                                ? "Disabled random theme."
                                : "Random color generation activated.")));
                      });
                    }
                }
              },
              icon: const Icon(Icons.settings),
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context) {
                return choices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              }),
        ],
      ),
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: const RouteSettings(name: "/home"),
                      builder: (context) => const AddTaskScreen()),
                );
                _updateTasks();
              },
              child: const Icon(
                Icons.note_add,
              ),
            )
          : IconButton(
              onPressed: () async {
                var result = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) => AddPlanAlertDialog(
                          tasks: tasks,
                        ));
                if (result == true) {
                  _updatePlans();
                }
              },
              icon: const Icon(Icons.add)),
      body: selectedIndex == 0
          ? TasksScreen(
              tasks: tasks,
            )
          : AgendaScreen(
              plans: plans,
              update: () {
                _updatePlans();
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
        ],
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
      ),
    );
  }
}
