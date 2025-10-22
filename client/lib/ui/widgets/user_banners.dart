import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/data/models/auth_utility.dart';
import 'package:flutter_to_do_app/ui/screens/register_page.dart';
import 'package:flutter_to_do_app/ui/screens/signup_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

AppBar userBanner(context, {VoidCallback? onTapped}) {
  return AppBar(
    // centerTitle: true,
    actions: [
      IconButton(
        icon: const Icon(FontAwesomeIcons.powerOff),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("No")),
                    TextButton(
                        onPressed: () {
                          AuthUtility.clearUserInfo();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  // builder: (context) => const SignUpPage()),
                                  builder: (context) => const RegisterPage()),
                              (route) => false);
                        },
                        child: const Text("Yes")),
                  ],
                );
              });
        },
      ),
    ],
    title: Center(
      child: SizedBox(
        height: 40,
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: GestureDetector(
            onTap: onTapped,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CircleAvatar(
                //   radius: 25,
                //   child: Image.memory(
                //     showBase64Image(AuthUtility.userInfo.data?.photo),
                //     errorBuilder: (_, __, ___) {
                //       return const Icon(Icons.person);
                //     },
                //   ),
                // ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AuthUtility.userInfo.user?.username ?? " ",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(AuthUtility.userInfo.user?.email ?? "",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

showBase64Image(base64String) {
  UriData? data = Uri.parse(base64String).data;
  Uint8List myImage = data!.contentAsBytes();
  return myImage;
}
