import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front/screens/HomeScreen.dart';

import 'db/db.dart';

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
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(colorSchemeSeed: const Color(0xFF991F3A)),
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
}
