import 'package:front/main.dart';
import 'package:front/models/task_class.dart';

import 'activity_log_class.dart';

class Plan {
  int localId = 0;
  int? remoteId;
  int? parentId;

  String name = "";
  int startsAt = DateTime.now().millisecondsSinceEpoch;
  int endsAt = DateTime.now().millisecondsSinceEpoch;
  bool completed = false;

  int createdAt = DateTime.now().millisecondsSinceEpoch;
  int modifiedAt = DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap({bool includeLocalId = true}) {
    var data = {
      'remoteId': remoteId,
      'parentId': parentId,
      'name': name,
      'startsAt': startsAt,
      'endsAt': endsAt,
      'createdAt': createdAt,
      'modifiedAt': modifiedAt,
      'completed': completed.asInt(),
    };
    if (includeLocalId) {
      data['localId'] = localId;
    }
    return data;
  }

  static Plan fromMap(Map<String, dynamic> map) {
    var task = Plan();
    task.localId = map['localId'];
    task.createdAt = map['createdAt'];
    task.modifiedAt = map['modifiedAt'];
    task.parentId = map['parentId'];
    task.remoteId = map['remoteId'];
    task.name = map['name'];
    task.startsAt = map['startsAt'];
    task.endsAt = map['endsAt'];
    task.completed = (map['completed'] as int?)?.asBool() ?? false;
    return task;
  }

  Task? relatesTo;

  Activity getActivity() {
    var asd = Activity();
    asd.planId = localId;
    asd.modifiedAt = endsAt;
    asd.createdAt = endsAt;
    asd.timeSpent = endsAt - startsAt;
    asd.parentId = parentId;
    asd.comment = name;
    return asd;
  }
}
