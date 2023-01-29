import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:front/screens/agenda/widgets/AgendaWidget.dart';
import 'package:jiffy/jiffy.dart';

import '../../models/plan_class.dart';

class AgendaScreen extends StatefulWidget {
  final List<Plan> plans;
  const AgendaScreen({super.key, required this.plans});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          Jiffy().MMMd,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 24.0),
        ),
        const SizedBox(height: 4.0),
        for (var plan in widget.plans) AgendaListWidget(plan: plan)
      ],
    );
  }
}
