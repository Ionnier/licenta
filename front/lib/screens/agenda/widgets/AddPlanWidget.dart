import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:front/data/task_local_repository.dart';
import 'package:select_form_field/select_form_field.dart';

import '../../../data/auth_repository.dart';
import '../../../main.dart';
import '../../../models/plan_class.dart';
import '../../../models/task_class.dart';
import '../../InputTask.dart';

class AddPlanAlertDialog extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _taskController = TextEditingController();

  final List<Task>? tasks;
  final int? initialSelected;

  AddPlanAlertDialog({super.key, this.tasks, this.initialSelected});

  @override
  Widget build(BuildContext context) {
    if (initialSelected != null) {
      _taskController.text = initialSelected!.toString();
    }
    List<Map<String, dynamic>> items = tasks != null
        ? List.generate(
            tasks!.length,
            (index) => {
                  "label": tasks![index].title,
                  "value": tasks![index].localId,
                })
        : List.empty(growable: true);
    items.add(
      {"label": "None", "value": null},
    );
    return AlertDialog(
      scrollable: true,
      title: const Text('Add plan'),
      content: Form(
        key: _formKey,
        child: Column(children: [
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'To do',
            ),
            controller: _nameController,
            validator: validateNotNullText,
          ),
          TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Start time',
              ),
              validator: validateOnlyNumbers,
              readOnly: true,
              controller: _startDateController,
              onTap: () {
                DatePicker.showDateTimePicker(
                  context,
                  showTitleActions: true,
                  currentTime: DateTime.now(),
                  onConfirm: (time) {
                    _startDateController.text =
                        time.millisecondsSinceEpoch.toString();
                  },
                );
              }),
          TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'End time',
              ),
              validator: validateOnlyNumbers,
              readOnly: true,
              controller: _endDateController,
              onTap: () {
                var start = int.tryParse(_startDateController.text) ??
                    DateTime.now().millisecondsSinceEpoch;
                DatePicker.showDateTimePicker(
                  context,
                  showTitleActions: true,
                  currentTime: DateTime.fromMillisecondsSinceEpoch(start),
                  onConfirm: (time) {
                    _endDateController.text =
                        time.millisecondsSinceEpoch.toString();
                  },
                );
              }),
          SelectFormField(
            type: SelectFormFieldType.dropdown,
            labelText: 'Link to task',
            items: items,
            controller: _taskController,
            enableSearch: true,
          ),
        ]),
      ),
      actions: <Widget>[
        const SuggestButton(),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (int.parse(_endDateController.text) <
                  int.parse(_startDateController.text)) {
                return;
              }
              try {
                _formKey.currentState!.save();
                var plan = Plan();
                plan.name = _nameController.text;
                plan.startsAt = int.tryParse(_startDateController.text)!;
                plan.endsAt = int.tryParse(_endDateController.text)!;
                plan.parentId = int.tryParse(_taskController.text);
                await LocalTaskDbRepository().insertPlan(plan, setTime: false);
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('There was an error with your request.'),
                ));
              }
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class SuggestButton extends StatefulWidget {
  const SuggestButton({super.key});

  @override
  State<SuggestButton> createState() => _SuggestButtonState();
}

class _SuggestButtonState extends State<SuggestButton> {
  bool isLoading = false;
  String? content;

  @override
  Widget build(BuildContext context) {
    Widget? asd;
    if (isLoading) {
      asd = const CircularProgressIndicator();
    } else if (content == null) {
      asd = TextButton(
          onPressed: () async {
            setState(() => {isLoading = true});
            var response = await Dio(BaseOptions(headers: {
              "Authorization": "Bearer ${AuthRepository().getKey()}"
            })).get("$domainURL/suggest/");
            if (response.statusCode == 200) {
              setState(() {
                content = response.data.toString();
              });
            }
            setState(() {
              isLoading = false;
            });
          },
          child: const Text("Suggest"));
    } else {
      asd = Text(content!);
    }
    return asd;
  }
}
