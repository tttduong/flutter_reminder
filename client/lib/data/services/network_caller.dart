import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/app.dart';
import 'package:flutter_to_do_app/data/models/auth_utility.dart';
import 'package:flutter_to_do_app/data/models/network_response.dart';
import 'package:flutter_to_do_app/ui/screens/login_page.dart';
import 'package:http/http.dart';

import '../../ui/screens/screens.dart';

class NetworkCaller {
  Future<NetworkResponse> getRequest(String url) async {
    try {
      Response response = await get(Uri.parse(url),
          headers: {'token': AuthUtility.userInfo.token.toString()});
      if (response.statusCode == 200) {
        return NetworkResponse(
            true, response.statusCode, jsonDecode(response.body));
      } else {
        return NetworkResponse(
          false,
          response.statusCode,
          null,
        );
      }
    } catch (e) {
      log(e.toString());
    }
    return NetworkResponse(
      false,
      -1,
      null,
    );
  }

  Future<NetworkResponse> postRequest(
    String url,
    Map<String, dynamic>? body,
  ) async {
    try {
      Response response = await post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'token': AuthUtility.userInfo.token.toString(),
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        return NetworkResponse(
            true, response.statusCode, jsonDecode(response.body));
      } else {
        return NetworkResponse(
          false,
          response.statusCode,
          null,
        );
      }
    } catch (e) {
      log(e.toString());
    }
    return NetworkResponse(
      false,
      -1,
      null,
    );
  }
}

void moveToLogin() async {
  await AuthUtility.clearUserInfo();
  // ignore: use_build_context_synchronously
  Navigator.pushAndRemoveUntil(
      TaskManagerApp.globalKey.currentState!.context,
      // MaterialPageRoute(builder: (context) => const SignInPage()),
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false);
}
