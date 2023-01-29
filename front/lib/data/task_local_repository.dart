import 'package:collection/collection.dart';
import 'package:front/main.dart';
import 'package:front/models/activity_log_class.dart';
import 'package:jiffy/jiffy.dart';
import 'package:sqflite/sqflite.dart';

import '../models/plan_class.dart';
import '../models/task_class.dart';
import '../db/db.dart';

class LocalTaskDbRepository implements LocalTaskRepository {
  @override
  Future<List<Task>> getTasks() async {
    final List<Map<String, dynamic>> maps =
        await AppDb().db!.rawQuery("SELECT * from $tasksTableName");
    var initialList = List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
    var groupByParentId =
        initialList.groupListsBy((element) => element.parentId);
    for (var element in initialList) {
      element.activities = await getActivities(element);
      element.subTasks = groupByParentId[element.localId];
    }
    return initialList;
  }

  Future<Task> getTask(int localId) async {
    final List<Map<String, dynamic>> maps = await AppDb()
        .db!
        .query(tasksTableName, where: "localId = ?", whereArgs: [localId]);
    var initialList = List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
    return initialList.first;
  }

  @override
  Future<List<Activity>> getActivities(Task task) async {
    final List<Map<String, dynamic>> maps = await AppDb().db!.rawQuery(
        "SELECT * from $activityTableName where parentId = ?", [task.localId]);
    var initialList = List.generate(maps.length, (i) {
      return Activity.fromMap(maps[i]);
    });
    return initialList;
  }

  Future<List<Activity>> getOnlyActivities() async {
    final List<Map<String, dynamic>> maps =
        await AppDb().db!.rawQuery("SELECT * from $activityTableName");
    List<Activity> initialList = List.empty(growable: true);
    for (var map in maps) {
      var asd = Activity.fromMap(map);
      if (asd.parentId != null) {
        asd.task = await getTask(asd.parentId!);
      } else if (asd.planId != null) {
        asd.plan = await getPlan(asd.planId!);
      }
      initialList.add(asd);
    }
    initialList.sort((a, b) => -a.modifiedAt + b.modifiedAt);
    return initialList;
  }

  @override
  Future<void> insertTask(Task task) async {
    task.createdAt = DateTime.now().millisecondsSinceEpoch;
    task.modifiedAt = task.createdAt;
    await AppDb().db!.insert(tasksTableName, task.toMap(includeLocalId: false),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return;
  }

  @override
  Future<void> updateTask(Task task) async {
    task.modifiedAt = DateTime.now().millisecondsSinceEpoch;
    await AppDb().db!.update(tasksTableName, task.toMap(includeLocalId: false),
        where: "localId = ?",
        whereArgs: [task.localId],
        conflictAlgorithm: ConflictAlgorithm.replace);
    return;
  }

  Future<int> _delete(String tableName, dynamic value) async {
    return await AppDb()
        .db!
        .delete(tableName, where: "localId = ?", whereArgs: [value.localId]);
  }

  @override
  Future<void> deleteTask(Task task) async {
    await _delete(tasksTableName, task.localId);
    return;
  }

  Future<void> insertActivity(Activity activity, {bool setTime = true}) async {
    if (setTime) {
      activity.createdAt = DateTime.now().millisecondsSinceEpoch;
      activity.modifiedAt = activity.createdAt;
    }
    await AppDb().db!.insert(
        activityTableName, activity.toMap(includeLocalId: false),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return;
  }

  Future<void> deleteActivity(Activity activity) async {
    await _delete(activityTableName, activity.localId);
    return;
  }

  Future<Plan> getPlan(int localId) async {
    final List<Map<String, dynamic>> maps = await AppDb()
        .db!
        .rawQuery("SELECT * from $planTableName where localId = ?", [localId]);

    var initialList = List.generate(maps.length, (i) {
      return Plan.fromMap(maps[i]);
    });
    return initialList.first;
  }

  Future<List<Plan>> getPlans() async {
    final now = DateTime.now();
    final lastMidnight = now.subtract(Duration(
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second,
      milliseconds: now.millisecond,
      microseconds: now.microsecond,
    ));
    final nextMidnight = lastMidnight.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await AppDb().db!.rawQuery(
        "SELECT * from $planTableName where endsAt > ? and startsAt < ?", [
      lastMidnight.millisecondsSinceEpoch,
      nextMidnight.millisecondsSinceEpoch,
    ]);

    var initialList = List.generate(maps.length, (i) {
      return Plan.fromMap(maps[i]);
    });
    initialList.sort((a, b) => a.startsAt - b.startsAt);
    return initialList;
  }

  Future<void> insertPlan(Plan plan, {bool setTime = true}) async {
    if (setTime) {
      plan.createdAt = DateTime.now().millisecondsSinceEpoch;
      plan.modifiedAt = plan.createdAt;
    }
    await AppDb().db!.insert(planTableName, plan.toMap(includeLocalId: false),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return;
  }

  Future<void> deletePlan(Plan plan) async {
    await _delete(activityTableName, plan.localId);
    return;
  }

  Future<void> markAsCompleted(Task task) async {
    task.lastCompletedAt = DateTime.now().millisecondsSinceEpoch;
    await updateTask(task);
    await insertActivity(task.getActivity(), setTime: false);
    return;
  }

  Future<void> deleteCompletion(Task task) async {
    await AppDb().db!.delete(activityTableName,
        where: "parentId = ? and createdAt = ?",
        whereArgs: [task.parentId, task.lastCompletedAt]);
    task.lastCompletedAt = 0;
    await updateTask(task);
    return;
  }

  Future<void> togglePlan(Plan plan) async {
    plan.modifiedAt = DateTime.now().millisecondsSinceEpoch;
    await AppDb().db!.update(
        planTableName, {"completed": plan.completed.asInt()},
        where: "localId = ?",
        whereArgs: [plan.localId],
        conflictAlgorithm: ConflictAlgorithm.replace);
    if (plan.completed) {
      await insertActivity(plan.getActivity(), setTime: false);
    } else {
      await AppDb().db!.delete(activityTableName,
          where: "planId = ?", whereArgs: [plan.localId]);
    }
    return;
  }
}

abstract class LocalTaskRepository {
  Future<List<Task>> getTasks();
  Future<void> insertTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(Task task);
}
