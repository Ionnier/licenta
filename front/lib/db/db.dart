import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class AppDb {
  static final AppDb _singleton = AppDb._internal();
  Database? db;
  SharedPreferences? sp;
  // Obtain shared preferences.

  factory AppDb() {
    return _singleton;
  }

  bool getRandomColor() {
    try {
      return sp!.getBool("randomColor") ?? true;
    } catch (e) {
      return false;
    }
  }

  Future<void> setRandomColor(bool value) async {
    await sp!.setBool("randomColor", value);
  }

  Future<void> initDb() async {
    sp = await SharedPreferences.getInstance();
    db = await openDatabase(
      join(await getDatabasesPath(), 'my_db.db'),
      onCreate: (db, version) async {
        await db.execute("create table $tasksTableName("
            "localId INTEGER PRIMARY KEY AUTOINCREMENT,"
            "remoteId INTEGER,"
            "parentId INTEGER,"
            "title TEXT,"
            "description TEXT,"
            "totalTimeEstimated INT,"
            "remainingTimeEstimated INT,"
            "prefferedSessionTime INT,"
            "priority INT,"
            "completed INT,"
            "archived INT,"
            "createdAt INT,"
            "lastCompletedAt INT,"
            "modifiedAt INT,"
            "foreign key(parentId) references tasks(localId) on delete cascade"
            ")");

        await db.execute("create table $activityTableName("
            "localId INTEGER PRIMARY KEY AUTOINCREMENT,"
            "remoteId INTEGER,"
            "parentId INTEGER,"
            "planId INTEGER,"
            "comment TEXT,"
            "startedAt INT,"
            "timeSpent INT,"
            "createdAt INT,"
            "modifiedAt INT,"
            "foreign key(parentId) references $tasksTableName(localId) on delete cascade,"
            "foreign key(planId) references $planTableName(localId) on delete cascade"
            ")");

        await db.execute("create table $planTableName("
            "localId INTEGER PRIMARY KEY AUTOINCREMENT,"
            "remoteId INTEGER,"
            "parentId INTEGER,"
            "name TEXT,"
            "startsAt INT,"
            "endsAt INT,"
            "createdAt INT,"
            "modifiedAt INT,"
            "completed INT,"
            "foreign key(parentId) references tasks(localId) on delete set null"
            ")");
        return;
      },
      version: 1,
    );
  }

  AppDb._internal();
}

const String tasksTableName = "tasks";
const String activityTableName = "activities";
const String planTableName = "plans";