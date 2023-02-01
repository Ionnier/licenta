import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:front/data/auth_repository.dart';
import 'package:front/data/task_local_repository.dart';
import 'package:front/db/db.dart';
import 'package:front/screens/AddTask.dart';
import 'package:front/screens/TasksScreen.dart';
import 'package:front/screens/activity/ActivityListScreen.dart';
import 'package:front/screens/agenda/AgendaScreen.dart';
import 'package:front/screens/agenda/widgets/AddPlanWidget.dart';
import 'package:front/screens/login/LoginScreen.dart';
import 'package:front/screens/timeline/TimelineScreen.dart';
import 'package:front/widgets/SyncInProgressDialog.dart';
import 'package:url_launcher/url_launcher.dart';

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

  final login = "Login";
  final logout = "Logout";

  @override
  Widget build(BuildContext context) {
    List<String> choices = ["Activity Log", "Toggle random color"];

    if (!AuthRepository().isLoggedIn()) {
      choices.add(login);
    } else {
      choices.add(logout);
      choices.add("Manage account");
    }

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
          if (AuthRepository().isLoggedIn())
            IconButton(
                onPressed: () async {
                  await showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => WillPopScope(
                          onWillPop: () async => false,
                          child: const SyncAlertDiaglog()));
                },
                icon: const Icon(Icons.sync)),
          PopupMenuButton(
              onSelected: (value) async {
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
                      break;
                    }
                  case 2:
                    {
                      if (!AuthRepository().isLoggedIn()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      } else {
                        var result = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: const Text("Confirm logout"),
                                  content: const Text(
                                      "Logging out will remove all data from this device. Make sure you synced your information."),
                                  actions: [
                                    TextButton(
                                      child: const Text("Cancel"),
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                    ),
                                    OutlinedButton(
                                        onPressed: () async {
                                          await AuthRepository().logout();
                                          if (context.mounted) {
                                            Navigator.pop(context, true);
                                          }
                                        },
                                        child: const Text("Confirm"))
                                  ],
                                ));
                        if (result == true) {
                          _updatePlans();
                          _updateTasks();
                        }
                        break;
                      }
                      break;
                    }
                  case 3:
                    {
                      var url = Uri.parse("https://www.flutter.dev");
                      if (!await launchUrl(url,
                          mode: LaunchMode.externalApplication)) {
                        throw Exception('Could not launch $url');
                      }
                      break;
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
          : (selectedIndex == 1
              ? IconButton(
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
                  icon: const Icon(Icons.add))
              : null),
      body: selectedIndex == 0
          ? TasksScreen(
              tasks: tasks,
            )
          : (selectedIndex == 1
              ? AgendaScreen(
                  plans: plans,
                  update: () {
                    _updatePlans();
                  },
                )
              : const TimelineScreen()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          if (AuthRepository().isLoggedIn())
            const BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Timeline',
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
