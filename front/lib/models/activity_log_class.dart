import 'package:front/models/plan_class.dart';
import 'package:front/models/task_class.dart';

class Activity {
  int localId = 0;
  int? remoteId;
  int? parentId;
  int? planId;

  String? comment;
  int createdAt = DateTime.now().millisecondsSinceEpoch;
  int modifiedAt = DateTime.now().millisecondsSinceEpoch;
  int? startedAt;
  int timeSpent = 0;

  Map<String, dynamic> toMap({bool includeLocalId = true}) {
    var data = {
      'remoteId': remoteId,
      'parentId': parentId,
      'comment': comment,
      'startedAt': startedAt,
      'timeSpent': timeSpent,
      'createdAt': createdAt,
      'modifiedAt': modifiedAt,
      'planId': planId,
    };
    if (includeLocalId) {
      data['localId'] = localId;
    }
    return data;
  }

  static Activity fromMap(Map<String, dynamic> map) {
    var task = Activity();
    task.comment = map['comments'];
    task.localId = map['localId'];
    task.createdAt = map['createdAt'];
    task.modifiedAt = map['modifiedAt'];
    task.parentId = map['parentId'];
    task.remoteId = map['remoteId'];
    task.timeSpent = map['timeSpent'];
    task.planId = map['planId'];
    return task;
  }

  Task? task;
  Plan? plan;
}
