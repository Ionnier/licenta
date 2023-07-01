import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:front/data/auth_repository.dart';
import 'package:front/main.dart';
import 'package:path/path.dart';

import '../db/db.dart';

class SyncAlertDiaglog extends StatefulWidget {
  const SyncAlertDiaglog({super.key});

  @override
  State<SyncAlertDiaglog> createState() => _SyncAlertDiaglogState();
}

class _SyncAlertDiaglogState extends State<SyncAlertDiaglog> {
  var isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  void startLoading() {
    setState(() {
      isLoading = true;
    });
  }

  void stopLoading() {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
          height: 64,
          width: 64,
          child: Center(
              child: CircularProgressIndicator(
            strokeWidth: 1.5,
          )));
    }
    return AlertDialog(
        content: Column(
      children: [
        const Text("Choose sync method"),
        FilledButton(
          onPressed: () async {
            startLoading();
            var formData = FormData.fromMap({
              'db': await MultipartFile.fromFile(
                  await AppDb().getActualDbPath(),
                  filename: 'upload.txt'),
            });
            var dio = Dio(BaseOptions(
              headers: {"Authorization": "Bearer ${AuthRepository().getKey()}"},
              receiveDataWhenStatusError: true,
            ));
            try {
              var response =
                  await dio.patch("${domainURL}/storage/sync", data: formData);
              if (response.statusCode == 200) {
                if (context.mounted) Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Upload succeded'),
                ));
              } else {
                if (context.mounted) Navigator.pop(context, false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('There was an error with your request.'),
                ));
                print(response.data);
              }
            } catch (e) {
              if (e is DioError) {
                print(e.message);
                print(e.response);
              }

              if (context.mounted) Navigator.pop(context, false);
              const SnackBar(content: Text("An error occured"));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('There was an error with your request.'),
              ));
            }
          },
          child: const Text("Upload data"),
        ),
        FilledButton(
          onPressed: () async {
            startLoading();
            try {
              var response = await Dio(BaseOptions(headers: {
                "Authorization": "Bearer ${AuthRepository().getKey()}"
              }, receiveDataWhenStatusError: true))
                  .download("${domainURL}/storage/db",
                      await AppDb().getActualDbPath());
              print(response.statusCode);
              stopLoading();
            } catch (e) {
              if (e is DioError) {
                print(e.response);
              }
              if (context.mounted) Navigator.pop(context, false);
              const SnackBar(content: Text("An error occured"));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('There was an error with your request.'),
              ));
            }
          },
          child: const Text("Download data"),
        ),
        FilledButton(
          onPressed: () async {
            if (context.mounted) Navigator.pop(context, false);
          },
          child: const Text("Cancel"),
        )
      ],
    ));
  }
}
