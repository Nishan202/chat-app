import 'dart:developer';

import 'package:chat_app/constant/image_path.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/services/remote/firebase_repository.dart';
import 'package:chat_app/ui/screens/contacts_screen.dart';
import 'package:chat_app/ui/screens/signIn_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  Logger logger = Logger();
  String fromId = "";
  @override
  void initState() {
    super.initState();
    getFromId();
  }

  void getFromId() async {
    fromId = await FirebaseRepository.getCurrentUserId() ?? '';
    setState(() {});
  }

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
      body: StreamBuilder(
        stream: FirebaseRepository.getLiveChatContactStream(fromId: fromId),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No chats available."));
          } else if (snapshot.hasData) {
            List<String> listUserId = List.generate(
              snapshot.data!.docs.length,
              (index) {
                List<dynamic> data =
                    snapshot.data!.docs[index].get('ids') as List<dynamic>;
                data.removeWhere((element) => element == fromId);
                return data[0];
              },
            );

            // logger.i("List of User IDs: $listUserId");

            return ListView.builder(
              itemCount: listUserId.length,
              itemBuilder: (_, index) {
                return FutureBuilder(
                  future: FirebaseRepository.getUserInfoById(
                    userId: listUserId[index],
                  ),
                  builder: (_, userSnapshot) {
                    if (userSnapshot.hasData) {
                      UserModel currentModel = UserModel.fromDoc(
                        userSnapshot.data?.data() ?? {},
                      );
                      return Card(
                        elevation: 3,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          style: ListTileStyle.drawer,
                          leading: CircleAvatar(
                            backgroundImage:
                                currentModel.profilePic != ""
                                    ? NetworkImage(
                                      currentModel.profilePic ?? '',
                                    )
                                    : AssetImage(
                                          ImagePath.default_profile_image_2,
                                        )
                                        as ImageProvider,
                          ),
                          title: Text(currentModel.name ?? ""),
                          subtitle: Text(currentModel.email ?? ""),
                          onTap:
                              () => Navigator.pushNamed(
                                context,
                                AppRoutes.CHAT_SCREEN,
                                arguments: {
                                  'userId': currentModel.userId,
                                  'name': currentModel.name,
                                  'profilePic': currentModel.profilePic,
                                },
                              ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                );
              },
            );
          } else {
            return Center(child: Text("No chats available."));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.pushNamed(context, AppRoutes.CONTACTS_SCREEN),
        child: Icon(Icons.add),
      ),
    );
  }
}
