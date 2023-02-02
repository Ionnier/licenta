import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:front/data/timeline_repository.dart';
import 'package:front/screens/timeline/ProfileScreen.dart';
import 'package:front/screens/timeline/TimelineListElement.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                          title: const Text("Insert email"),
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
        TimelineElement(onProfileClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }),
        TimelineElement(
          onProfileClick: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
      ],
    );
  }
}
