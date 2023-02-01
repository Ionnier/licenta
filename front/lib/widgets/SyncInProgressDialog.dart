import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class SyncAlertDiaglog extends StatefulWidget {
  const SyncAlertDiaglog({super.key});

  @override
  State<SyncAlertDiaglog> createState() => _SyncAlertDiaglogState();
}

class _SyncAlertDiaglogState extends State<SyncAlertDiaglog> {
  var isLoading = true;
  @override
  void initState() {
    super.initState();
    startLoading();
  }

  void startLoading() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      if (context.mounted) Navigator.pop(context);
    }
    return const SizedBox(
        height: 64,
        width: 64,
        child: Center(
            child: CircularProgressIndicator(
          strokeWidth: 1.5,
        )));
  }
}
