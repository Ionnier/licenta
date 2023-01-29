import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:front/data/task_local_repository.dart';
import 'package:front/db/db.dart';
import 'package:select_form_field/select_form_field.dart';

import '../../../models/plan_class.dart';
import '../../InputTask.dart';

class AddPlanAlertDialog extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _taskController = TextEditingController();

  AddPlanAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
            items: const [
              {"label": "None", "value": null},
              {
                "label": "asd",
                "value": "bsd",
              }
            ],
            controller: _taskController,
          ),
        ]),
      ),
      actions: <Widget>[
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
