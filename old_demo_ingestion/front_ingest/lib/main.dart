import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

Map<String, dynamic> createItem(name) {
  return {
    'value': name,
    'label': name,
  };
}

final List<Map<String, dynamic>> _items = [
  createItem("Well-Being"),
  createItem("Relax"),
  createItem("Sport"),
  createItem("Study"),
  createItem("Work"),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: const SafeArea(
          child: MyHomePage(title: 'Flutter Demo Home Page'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

String? validateNumber(String? value) {
  if (value == null) return null;
  List<String> validChar = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  for (int i = 0; i < value.length; i++) {
    if (!validChar.contains(value[i])) {
      return "Error";
    }
  }
  return null;
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool isInfinite = false;
  DateTime? date = null;
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final taskNameController = TextEditingController();
  final sessionDurationController = TextEditingController();
  final totalController = TextEditingController();
  final remainingController = TextEditingController();
  String? selectedCategory = "";

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    taskNameController.dispose();
    sessionDurationController.dispose();
    totalController.dispose();
    remainingController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Invoke "debug painting" (press "p" in the console, choose the
              // "Toggle Debug Paint" action from the Flutter Inspector in Android
              // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
              // to see the wireframe for each widget.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (date != null) Text("Selected day is: $date"),
                TextButton(
                  onPressed: () {
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true, onConfirm: (date2) {
                      setState(() {
                        date = date2;
                      });
                    }, currentTime: DateTime.now(), locale: LocaleType.en);
                  },
                  child: const Text(
                    'Select date',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Task name',
                  ),
                  controller: taskNameController,
                ),
                SelectFormField(
                  type: SelectFormFieldType.dropdown, // or can be dialog
                  initialValue: 'circle',
                  labelText: 'Category',
                  items: _items,
                  onChanged: (val) => setState(() {
                    selectedCategory = val;
                  }),
                  onSaved: (val) => (val) => setState(() {
                        selectedCategory = val;
                      }),
                ),
                CheckboxListTile(
                  title: Text("Does not end"),
                  value: isInfinite,
                  onChanged: (newValue) {
                    setState(() {
                      if (newValue == true) {
                        isInfinite = true;
                      } else {
                        isInfinite = false;
                      }
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                if (!isInfinite)
                  Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Total time',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: validateNumber,
                        controller: totalController,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Time remaining before session',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: validateNumber,
                        controller: remainingController,
                      ),
                    ],
                  ),
                TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Session duration',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validateNumber,
                  controller: sessionDurationController,
                ),
                TextButton(
                  onPressed: () async {
                    Map<String, dynamic?> data = {};
                    if (date != null) {
                      data["timestamp"] =
                          date?.millisecondsSinceEpoch.toString().trim();
                    }
                    data["category"] = selectedCategory!.trim();
                    data["name"] = taskNameController.text.trim();
                    data["sessionTime"] = sessionDurationController.text.trim();
                    if (!isInfinite) {
                      data["completionTime"] = totalController.text.trim();
                      data["remainingTime"] = remainingController.text.trim();
                    }
                    var url = Uri.http(
                        'ionniertest.eu-4.evennode.com', 'api/insert', data);
                    bool isvalid = true;
                    data.forEach((key, value) {
                      if (value == null || value == "") {
                        isvalid = false;
                      }
                    });
                    if (isvalid) {
                      var response = await http
                          .post(url, body: {'name': 'doodle', 'color': 'blue'});
                      if (response.statusCode == 200) {
                        setState(() {
                          isInfinite = false;
                          totalController.clear();
                          remainingController.clear();
                          taskNameController.clear();
                          date = null;
                          sessionDurationController.clear();
                        });
                      }
                      print(url);
                    }
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
