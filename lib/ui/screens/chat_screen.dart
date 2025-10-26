import 'dart:async';

import 'package:chat_app/constant/image_path.dart';
import 'package:chat_app/model/message_model.dart';
import 'package:chat_app/services/remote/firebase_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageModel> chatMessages = [];
  String fromId = "";
  String toId = "";
  Map<String, dynamic>? argsMap;
  StreamSubscription? _chatSubscription;
  TextEditingController messageController = TextEditingController();
  // Use 12-hour format with AM/PM
  DateFormat dateFormat = DateFormat.jm();

  String getFormattedTime(String? sendAt) {
    if (sendAt == null) return '';
    final millis = int.tryParse(sendAt);
    if (millis == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);
    return dateFormat.format(dt);
  }

  @override
  void initState() {
    super.initState();

    // After the first frame, if toId is still empty, try ModalRoute arguments as a fallback.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      if (routeArgs != null && routeArgs is Map<String, dynamic>) {
        argsMap = routeArgs;
        toId = argsMap?['userId'] ?? '';
      }

      initializeChatRoom();
    });
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    messageController.dispose();
    super.dispose();
  }

  void initializeChatRoom() async {
    fromId = await FirebaseRepository.getCurrentUserId() ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // final args = argsMap ?? (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {});
    return Scaffold(
      appBar: AppBar(
        // Reserve enough width for back button + avatar to avoid overflow
        leadingWidth: 100,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BackButton(onPressed: () => Navigator.pop(context)),
            SizedBox(width: 6),
            CircleAvatar(
              radius: 18,
              backgroundImage:
                  (argsMap?['profilePic'] != null &&
                          (argsMap?['profilePic'] as String).isNotEmpty)
                      ? NetworkImage(argsMap?['profilePic'])
                      : AssetImage(ImagePath.default_profile_image_2)
                          as ImageProvider,
            ),
          ],
        ),
        title: Text(
          argsMap?['name'] ?? "No title",
          style: TextStyle(color: Colors.grey),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat messages
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseRepository.getChatStream(
                  toId: toId,
                  fromId: fromId,
                ),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  chatMessages =
                      snapshot.data?.docs
                          .map((d) => MessageModel.fromJson(d.data()))
                          .toList() ??
                      [];
                  if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No messages yet."));
                  }
                  return ListView.builder(
                    // reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: chatMessages.length,
                    itemBuilder: (_, index) {
                      final message = chatMessages[index];
                      return Align(
                        alignment:
                            message.receiverId != fromId
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child:
                              message.receiverId == fromId
                                  ? _senderChatBox(message)
                                  : _receiverChatBox(message),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Message input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.grey[200],
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (toId != '') {
                          FirebaseRepository.sendTextMessage(
                            toId: toId,
                            message: messageController.text,
                          );
                          messageController.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // left side chat box (receiver)
  Widget _receiverChatBox(MessageModel message) {
    return Container(
      constraints: BoxConstraints(maxWidth: 250),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.message ?? '',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            getFormattedTime(message.sendAt),
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // right side chat box (sender)
  Widget _senderChatBox(MessageModel message) {
    return Container(
      constraints: BoxConstraints(maxWidth: 250),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green[200],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            message.message ?? '',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            getFormattedTime(message.sendAt),
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
