import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:front/main.dart';

import 'auth_repository.dart';

class TimelineRepository {
  static final TimelineRepository _singleton = TimelineRepository._internal();

  factory TimelineRepository() {
    return _singleton;
  }

  TimelineRepository._internal();

  Future<bool> followUser(String email) async {
    try {
      var result =
          await Dio(BaseOptions(receiveDataWhenStatusError: true, headers: {
        "Authorization": "Bearer ${AuthRepository().getKey()}",
      })).post("${domainURL}/timeline/friends",
              data: json.encode({"friendId": email}));
      if (result.statusCode == 200) {
        return true;
      } else {
        print(result.data);
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
