import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/services/remote/firebase_repository.dart';
import 'package:chat_app/ui/screens/contacts_screen.dart';
import 'package:chat_app/ui/screens/signIn_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              // Implement refresh functionality here
              // await FirebaseAuth.instance.signOut();
              FirebaseRepository.signOut();
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.LOGIN_SCREEN_ROUTE,
              );
            },
          ),
        ],
      ),
      // body: ,
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.pushNamed(context, AppRoutes.CONTACTS_SCREEN),
        child: Icon(Icons.add),
      ),
    );
  }
}
