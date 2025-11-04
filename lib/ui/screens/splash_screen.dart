import 'dart:async';

import 'package:chat_app/constant/image_path.dart';
import 'package:chat_app/services/remote/firebase_repository.dart';
import 'package:chat_app/ui/screens/signIn_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_list_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () async {
      SharedPreferences preference = await SharedPreferences.getInstance();
      String? value = preference.getString(FirebaseRepository.prefsUserId);
      // String? token = preference.getString('token');

      //
      Widget navigateTo = SigninScreen();
      //
      // if(token != null){
      //   // navigateTo = HomeScreen();
      // }
      if (value != null && value != "") {
        navigateTo = ChatListScreen();
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => navigateTo),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Image.asset(ImagePath.splash_screen_image, fit: BoxFit.cover),
            const SizedBox(height: 20),
            const Text(
              'Confirm your order and await delivery',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              'Choose from a wide range of deliver options',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const Text(
              'eShop, pickup point or at your doorstep',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
