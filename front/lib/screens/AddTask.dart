import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:front/screens/InputTask.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose type"),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(
              child: AddTaskActivityCard(
                title: "Activity",
                description: "Start an activity. It will be finished.",
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InputTaskScreen(
                              activityType: activityType,
                            )),
                  )
                },
              ),
            ),
            Expanded(
              child: AddTaskActivityCard(
                title: "Habit",
                description: "Start a habit. They won't finish.",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InputTaskScreen(
                              activityType: habitType,
                            )),
                  );
                },
              ),
            ),
          ]),
        ),
      )),
    );
  }
}

class AddTaskActivityCard extends StatelessWidget {
  final String title;
  final String description;
  final Function onPressed;
  const AddTaskActivityCard(
      {super.key,
      required this.title,
      required this.description,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title),
            Text(
              description,
              textAlign: TextAlign.center,
            ),
            OutlinedButton(
                onPressed: () => {onPressed()}, child: const Text("Start"))
          ],
        )),
      ),
    );
  }
}
