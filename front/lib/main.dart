import 'dart:math';

import 'package:flutter/material.dart';
import 'package:front/screens/HomeScreen.dart';

import 'db/db.dart';

const domainURL = "http://ionnier.com";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDb().initDb();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var color = Colors.white;
    if (AppDb().getRandomColor() == true) {
      final random = Random();
      color = Color.fromARGB(random.nextInt(256), random.nextInt(256),
          random.nextInt(256), random.nextInt(256));
    }
    return MaterialApp(
        title: 'Scheduler',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: color)),
        home: Builder(
          builder: (context) => const MyWidget(),
        ));
  }
}

extension AsInt on bool {
  int asInt() {
    if (this) {
      return 1;
    }
    return 0;
  }
}

extension AsBool on int {
  bool asBool() => this == 1;

  DateTime fromEpoch() =>
      DateTime.fromMillisecondsSinceEpoch(this, isUtc: true);

  DateTime fromUnix() =>
      DateTime.fromMillisecondsSinceEpoch(this * 1000, isUtc: true);
}
