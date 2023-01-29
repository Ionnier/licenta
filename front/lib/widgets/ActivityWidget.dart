import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:front/main.dart';
import 'package:jiffy/jiffy.dart';

import '../models/activity_log_class.dart';

class ActivityWidget extends StatefulWidget {
  final Activity activity;
  const ActivityWidget({super.key, required this.activity});

  @override
  State<ActivityWidget> createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget> {
  Activity activity = Activity();

  @override
  void initState() {
    activity = widget.activity;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            if (activity.comment != null) Text(activity.comment!),
            Text(Duration(milliseconds: activity.timeSpent)
                .toString()
                .split(".")[0]),
          ],
        ),
        const Spacer(),
        Text(Jiffy.unixFromMillisecondsSinceEpoch(
                activity.createdAt.fromEpoch().millisecondsSinceEpoch)
            .yMMMd
            .toString()),
      ],
    );
  }
}
