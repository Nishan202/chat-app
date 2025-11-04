import 'package:chat_app/constant/image_path.dart';
import 'package:chat_app/model/message_model.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/services/remote/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  Logger logger = Logger();
  String fromId = "";
  final DateFormat _timeFormat = DateFormat('h.mm a');

  String _formatSendAt(String? sendAt) {
    if (sendAt == null) return '';
    final millis = int.tryParse(sendAt);
    if (millis == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);
    return _timeFormat.format(dt).toLowerCase();
  }

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
              FirebaseRepository.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Logged out successfully")),
              );
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
                          subtitle: StreamBuilder(
                            stream: FirebaseRepository.getLastMessage(
                              toId: currentModel.userId ?? '',
                              fromId: fromId,
                            ),
                            builder: (_, lastMessageSnapshot) {
                              if (lastMessageSnapshot.hasData &&
                                  lastMessageSnapshot.data!.docs.isNotEmpty) {
                                MessageModel lastMessage =
                                    MessageModel.fromJson(
                                      lastMessageSnapshot.data!.docs[0].data(),
                                    );
                                return lastMessage.senderId == fromId
                                    ? Row(
                                      children: [
                                        Icon(
                                          Icons.done_all_rounded,
                                          size: 16,
                                          color:
                                              lastMessage.readAt != ""
                                                  ? Colors.blue
                                                  : Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            lastMessage.messageType == 0
                                                ? lastMessage.message ?? ""
                                                : "📷 Photo",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    )
                                    : Text(
                                      lastMessage.messageType == 0
                                          ? lastMessage.message ?? ""
                                          : "📷 Photo",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    );
                              }
                              return SizedBox.shrink();
                            },
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              StreamBuilder(
                                stream: FirebaseRepository.getLastMessage(
                                  toId: currentModel.userId ?? '',
                                  fromId: fromId,
                                ),
                                builder: (_, lastMessageSnapshot) {
                                  if (lastMessageSnapshot.hasData &&
                                      lastMessageSnapshot
                                          .data!
                                          .docs
                                          .isNotEmpty) {
                                    MessageModel lastMessage =
                                        MessageModel.fromJson(
                                          lastMessageSnapshot.data!.docs[0]
                                              .data(),
                                        );
                                    return Text(
                                      _formatSendAt(lastMessage.sendAt),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    );
                                  }
                                  return SizedBox.shrink();
                                },
                              ),
                              StreamBuilder(
                                stream:
                                    FirebaseRepository.getUnreadMessageCount(
                                      toId: currentModel.userId ?? '',
                                      fromId: fromId,
                                    ),
                                builder: (_, undreadMessageCountSnapShot) {
                                  Logger().i(
                                    "Unread Message Count Snapshot: ${undreadMessageCountSnapShot.data?.docs.length}",
                                  );
                                  if (undreadMessageCountSnapShot.hasData &&
                                      undreadMessageCountSnapShot
                                          .data!
                                          .docs
                                          .isNotEmpty) {
                                    return CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.greenAccent,
                                      child: Text(
                                        '${undreadMessageCountSnapShot.data!.docs.length}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }

                                  return SizedBox.shrink();
                                },
                              ),
                            ],
                          ),

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
