import 'package:chat_app/ui/screens/signIn_screen.dart';
import 'package:chat_app/ui/screens/signup_screen.dart';
import 'package:flutter/material.dart';

import '../ui/screens/splash_screen.dart';

class AppRoutes {
  static const String SPLASH_SCREEN_ROUTE = '/splash';
  static const String BOTTOM_NAVIGATION_BAR = '/';
  static const String HOME_SCREEN_ROUTE = '/home';
  static const String LOGIN_SCREEN_ROUTE = '/login';
  static const String REGISTRATION_SCREEN_ROUTE = '/registration';

  static Map<String, WidgetBuilder> pageRoute = {
    SPLASH_SCREEN_ROUTE : (_) => SplashScreen(),
    // BOTTOM_NAVIGATION_BAR : (_) => BottomNavigation(),
    // HOME_SCREEN_ROUTE : (_) => HomeScreen(),
    // NOTIFICATION_SCREEN_ROUTE : (_) => NotificationScreen(),
    // STATISTICS_SCREEN_ROUTE : (_) => StatisticsScreen(),
    LOGIN_SCREEN_ROUTE : (_) => SigninScreen(),
    REGISTRATION_SCREEN_ROUTE : (_) => SignupScreen()
  };
}