import 'package:chat_app/constant/image_path.dart';
import 'package:chat_app/model/message_model.dart';
import 'package:chat_app/services/remote/firebase_repository.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageModel> chatMessages = [];
  TextEditingController messageController = TextEditingController();
  // Mock chat messages
  final List<Map<String, dynamic>> messages = const [
    {'message': "Hello! How are you?", 'isSender': false, 'sendAt': "10:00 AM"},
    {
      'message': "I'm good, thanks! How about you?",
      'isSender': true,
      'sendAt': "10:01 AM",
    },
    {'message': "Doing well!", 'isSender': false, 'sendAt': "10:02 AM"},
    {'message': "Great to hear!", 'isSender': true, 'sendAt': "10:03 AM"},
  ];

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        // leading: RichText(
        //   text: TextSpan(
        //     text: "Dig",
        //     style: TextStyle(
        //       color: Colors.black,
        //       fontSize: 20,
        //       fontWeight: FontWeight.normal,
        //     ),
        //     children: [
        //       TextSpan(
        //         text: "IT",
        //         style: TextStyle(
        //           fontSize: 20,
        //           fontWeight: FontWeight.bold,
        //           color: Colors.blue,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: CircleAvatar(
            backgroundImage:
                args['profilePic'] != null || args['profilePic'] != ""
                    ? NetworkImage(args['profilePic'])
                    : AssetImage(ImagePath.default_profile_image_2)
                        as ImageProvider,
          ),
        ),
        title: Text(
          args['name'] ?? "No title",
          style: TextStyle(color: Colors.grey),
        ),
        centerTitle: false,
        // actions: [
        //   Container(
        //     width: 30,
        //     height: 30,
        //     decoration: BoxDecoration(
        //       shape: BoxShape.circle,
        //       color: Colors.grey,
        //     ),
        //     child: Center(
        //       child: Icon(
        //         Icons.face_unlock_sharp,
        //         color: Colors.white,
        //         size: 19,
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            // Padding(
            //   padding: const EdgeInsets.symmetric(
            //     horizontal: 16.0,
            //     vertical: 12.0,
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       RichText(
            //         text: TextSpan(
            //           text: "Dig",
            //           style: TextStyle(
            //             color: Colors.black,
            //             fontSize: 20,
            //             fontWeight: FontWeight.normal,
            //           ),
            //           children: [
            //             TextSpan(
            //               text: "IT",
            //               style: TextStyle(
            //                 fontSize: 20,
            //                 fontWeight: FontWeight.bold,
            //                 color: Colors.blue,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //       Row(
            //         children: [
            //           Image.asset(
            //             ImagePath.default_profile_image,
            //             width: 30,
            //             height: 30,
            //           ),
            //           SizedBox(width: 10),
            //           Text(
            //             args['name'] ?? "No title",
            //             style: TextStyle(color: Colors.grey),
            //           ),
            //         ],
            //       ),
            //       Container(
            //         width: 30,
            //         height: 30,
            //         decoration: BoxDecoration(
            //           shape: BoxShape.circle,
            //           color: Colors.grey,
            //         ),
            //         child: Center(
            //           child: Icon(
            //             Icons.face_unlock_sharp,
            //             color: Colors.white,
            //             size: 19,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Divider(height: 1),
            // Chat messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Align(
                    alignment:
                        message['isSender']
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child:
                          message['isSender']
                              ? _senderChatBox(message)
                              : _receiverChatBox(message),
                    ),
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
                        FirebaseRepository.sendTextMessage(
                          toId: args['userId'],
                          message: messageController.text,
                        );
                        messageController.clear();
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
  Widget _receiverChatBox(Map<String, dynamic> message) {
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
            message['message'],
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            message['sendAt'],
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // right side chat box (sender)
  Widget _senderChatBox(Map<String, dynamic> message) {
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
            message['message'],
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            message['sendAt'],
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
