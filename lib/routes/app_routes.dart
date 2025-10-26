import 'package:chat_app/ui/screens/chat_list_screen.dart';
import 'package:chat_app/ui/screens/chat_screen.dart';
import 'package:chat_app/ui/screens/contacts_screen.dart';
import 'package:chat_app/ui/screens/signIn_screen.dart';
import 'package:chat_app/ui/screens/signup_screen.dart';
import 'package:flutter/material.dart';

import '../ui/screens/splash_screen.dart';

class AppRoutes {
  static const String SPLASH_SCREEN_ROUTE = '/splash';
  static const String CHAT_SCREEN = '/chat_screen';
  // static const String HOME_SCREEN_ROUTE = '/home';
  static const String LOGIN_SCREEN_ROUTE = '/login';
  static const String REGISTRATION_SCREEN_ROUTE = '/registration';
  static const String CHATLIST_SCREEN = '/chat_list_screen';
  static const String CONTACTS_SCREEN = '/contacts_screen';

  static Map<String, WidgetBuilder> pageRoute = {
    SPLASH_SCREEN_ROUTE: (_) => SplashScreen(),
    CHAT_SCREEN: (_) => ChatScreen(),
    // HOME_SCREEN_ROUTE : (_) => HomeScreen(),
    // NOTIFICATION_SCREEN_ROUTE : (_) => NotificationScreen(),
    // STATISTICS_SCREEN_ROUTE : (_) => StatisticsScreen(),
    LOGIN_SCREEN_ROUTE: (_) => SigninScreen(),
    REGISTRATION_SCREEN_ROUTE: (_) => SignupScreen(),
    CHATLIST_SCREEN: (_) => ChatListScreen(),
    CONTACTS_SCREEN: (_) => ContactsScreen(),
  };

  // Helper to open ChatScreen by directly constructing it with arguments.
  // This avoids relying on route arguments (ModalRoute or Get.arguments).
  // static Future openChatScreen(
  //   BuildContext context, {
  //   required String userId,
  //   String? name,
  //   String? profilePic,
  // }) {
  //   return Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder:
  //           (_) =>
  //               ChatScreen(userId: userId, name: name, profilePic: profilePic),
  //     ),
  //   );
  // }
}
