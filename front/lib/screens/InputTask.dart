import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:front/data/task_local_repository.dart';
import 'package:front/models/task_class.dart';
import 'package:select_form_field/select_form_field.dart';

const String activityType = "Activity";
const String habitType = "Habit";

class InputTaskScreen extends StatefulWidget {
  final String activityType;
  final int? parentId;
  final Task? task;
  const InputTaskScreen(
      {super.key, required this.activityType, this.parentId, this.task});

  @override
  State<InputTaskScreen> createState() => _InputTaskScreenState();
}

String? validateNotNullText(String? value) {
  if (value == null || (value.isEmpty == true)) {
    return "Enter some data";
  }
  return null;
}

String? validateOnlyNumbers(String? value) {
  var notNull = validateNotNullText(value);
  if (notNull != null) {
    return notNull;
  }

  final number = num.tryParse(value!);

  if (number == null) {
    return "Enter a number";
  }

  return null;
}

class _InputTaskScreenState extends State<InputTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  Task task = Task();

  TextEditingController totalTimeController = TextEditingController();
  TextEditingController prefferedTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    prefferedTimeController.text =
        widget.task?.prefferedSessionTime.toString() ?? "";
    totalTimeController.text = widget.task?.totalTimeEstimated.toString() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Input"),
        ),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Title',
                  ),
                  initialValue: widget.task?.title,
                  validator: validateNotNullText,
                  onSaved: (value) {
                    task.title = value!;
                  },
                ),
                const SizedBox(
                  height: 4.0,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Description',
                  ),
                  validator: validateNotNullText,
                  initialValue: widget.task?.description,
                  onSaved: (value) {
                    task.description = value!;
                  },
                ),
                const SizedBox(
                  height: 4.0,
                ),
                SelectFormField(
                  type: SelectFormFieldType.dialog,
                  labelText: 'Priority',
                  initialValue: widget.task?.priority.toString(),
                  items: prioritiesSelectFieldItems,
                  onSaved: (value) =>
                      task.priority = int.tryParse(value!) ?? lowPriority,
                ),
                const SizedBox(
                  height: 4.0,
                ),
                TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Preffered session duration',
                    ),
                    validator: validateOnlyNumbers,
                    onSaved: (value) {
                      task.prefferedSessionTime = int.tryParse(value!);
                    },
                    readOnly: true,
                    controller: prefferedTimeController,
                    onTap: () {
                      var date = DateTime.now();
                      DatePicker.showTimePicker(context,
                          showTitleActions: true,
                          currentTime: DateTime(date.year, date.month, date.day)
                              .add(Duration(
                                  milliseconds: int.tryParse(
                                          prefferedTimeController.text) ??
                                      0)), onConfirm: (date) {
                        prefferedTimeController.text = date
                            .difference(
                                DateTime(date.year, date.month, date.day))
                            .inMilliseconds
                            .toString();
                      });
                    }),
                const SizedBox(
                  height: 4.0,
                ),
                widget.activityType == activityType
                    ? TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Total time needed',
                        ),
                        readOnly: true,
                        controller: totalTimeController,
                        onTap: () {
                          var date = DateTime.now();
                          DatePicker.showTimePicker(context,
                              showTitleActions: true,
                              currentTime:
                                  DateTime(date.year, date.month, date.day).add(
                                      Duration(
                                          milliseconds: int.tryParse(
                                                  totalTimeController.text) ??
                                              0)), onConfirm: (date) {
                            totalTimeController.text = date
                                .difference(
                                    DateTime(date.year, date.month, date.day))
                                .inMilliseconds
                                .toString();
                          });
                        },
                        validator: validateOnlyNumbers,
                        onSaved: (value) {
                          task.totalTimeEstimated = int.tryParse(value!);
                        },
                      )
                    : const SizedBox(
                        height: 0.0,
                      ),
                widget.activityType == activityType
                    ? const SizedBox(
                        height: 4.0,
                      )
                    : const SizedBox(
                        height: 0.0,
                      ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        _formKey.currentState!.save();
                        task.parentId = widget.parentId;
                        if (widget.task != null) {
                          widget.task?.title = task.title;
                          widget.task?.description = task.description;
                          widget.task?.priority = task.priority;
                          widget.task?.prefferedSessionTime =
                              task.prefferedSessionTime;
                          widget.task?.totalTimeEstimated =
                              task.totalTimeEstimated;
                          await LocalTaskDbRepository()
                              .updateTask(widget.task!);
                        } else {
                          await LocalTaskDbRepository().insertTask(task);
                        }
                        if (context.mounted) {
                          Navigator.of(context)
                              .popUntil((route) => route.settings.name == "/");
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content:
                              Text('There was an error with your request.'),
                        ));
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        )));
  }
}
