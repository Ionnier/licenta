import 'package:front/main.dart';
import 'package:front/models/activity_log_class.dart';
import 'package:jiffy/jiffy.dart';

class Task {
  int localId = 0;
  int? remoteId;
  int? parentId;
  int? remoteParentId;
  String title = "";
  String description = "";
  List<Task>? subTasks;
  int? totalTimeEstimated;
  int? remainingTime;
  int? prefferedSessionTime;
  int priority = lowPriority;
  bool completed = false;
  bool archived = false;
  int createdAt = DateTime.now().millisecondsSinceEpoch;
  int modifiedAt = DateTime.now().millisecondsSinceEpoch;
  int lastCompletedAt = 0;
  List<Activity>? activities;

  Map<String, dynamic> toMap({bool includeLocalId = true}) {
    var data = {
      'remoteId': remoteId,
      'parentId': parentId,
      'title': title,
      'description': description,
      'totalTimeEstimated': totalTimeEstimated,
      'prefferedSessionTime': prefferedSessionTime,
      'priority': priority,
      'completed': completed.asInt(),
      'archived': archived.asInt(),
      'createdAt': createdAt,
      'modifiedAt': modifiedAt,
      'lastCompletedAt': lastCompletedAt,
    };
    if (includeLocalId) {
      data['localId'] = localId;
    }
    return data;
  }

  bool isHabit() => totalTimeEstimated == null;
  bool isDoable() => subTasks == null;
  bool isDoneToday() =>
      Jiffy().dayOfYear ==
      Jiffy(DateTime.fromMillisecondsSinceEpoch(lastCompletedAt)).dayOfYear;

  Task({this.title = "", this.description = ""});

  int getTaskActivitiesDuration() {
    int sum = 0;
    if (activities == null || activities!.isEmpty) {
      return sum;
    }
    for (var activity in activities!) {
      sum += activity.timeSpent;
    }
    return sum;
  }

  int getSubTasksTotalTimeSpent() {
    int sum = 0;
    try {
      if (subTasks == null) {
        return 0;
      }
      for (var task2 in subTasks!) {
        sum += task2.getTaskActivitiesDuration();
      }
      return sum;
    } catch (e) {
      return 0;
    }
  }

  static Task fromMap(Map<String, dynamic> map) {
    var task = Task(
      title: map['title'],
      description: map['description'],
    );
    task.localId = map['localId'];
    task.archived = (map['archived'] as int?)?.asBool() ?? false;
    task.completed = (map['completed'] as int?)?.asBool() ?? false;
    task.createdAt = map['createdAt'];
    task.modifiedAt = map['modifiedAt'];
    task.parentId = map['parentId'];
    task.lastCompletedAt = map['lastCompletedAt'];
    task.prefferedSessionTime = map['prefferedSessionTime'];
    task.priority = map['priority'];
    task.remoteId = map['remoteId'];
    task.totalTimeEstimated = map['totalTimeEstimated'];
    return task;
  }

  Activity getActivity() {
    var asd = Activity();
    asd.parentId = localId;
    asd.modifiedAt = lastCompletedAt;
    asd.createdAt = lastCompletedAt;
    asd.timeSpent = prefferedSessionTime ?? 0;
    return asd;
  }
}

const int lowPriority = 0;
const int mediumPriority = 1;
const int highPriority = 2;

const prioritiesSelectFieldItems = [
  {
    'value': lowPriority,
    'label': "Low priority",
  },
  {
    'value': mediumPriority,
    'label': "Medium priority",
  },
  {
    'value': highPriority,
    'label': "High priority",
  }
];
