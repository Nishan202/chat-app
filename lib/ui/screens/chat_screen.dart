import 'dart:async';
import 'dart:io';

import 'package:chat_app/constant/image_path.dart';
import 'package:chat_app/model/message_model.dart';
import 'package:chat_app/services/remote/firebase_repository.dart';
import 'package:chat_app/ui/widgets/attachment_bottom_sheet.dart';
import 'package:chat_app/ui/widgets/selected_attachments_preview.dart';
import 'package:chat_app/ui/widgets/image_grid_widget.dart';
import 'package:chat_app/ui/widgets/image_viewer.dart';
import 'package:chat_app/services/attachment/attachment_actions.dart';
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
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  // Use 12-hour format with AM/PM
  DateFormat dateFormat = DateFormat.jm();
  final ValueNotifier<List<SelectedAttachment>> selectedAttachmentsNotifier =
      ValueNotifier<List<SelectedAttachment>>([]);

  bool isLoadingMore = false;
  bool hasMoreMessages = true;
  bool isInitialLoad = true;
  static const int messagesPerPage = 20;

  String getFormattedTime(String? sendAt) {
    if (sendAt == null) return '';
    final millis = int.tryParse(sendAt);
    if (millis == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);
    return dateFormat.format(dt);
  }

  DateTime? getMessageDate(String? sendAt) {
    if (sendAt == null) return null;
    final millis = int.tryParse(sendAt);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      // Format as "MMM dd, yyyy" or "dd/MM/yyyy"
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  Widget _buildDateSeparator(String dateText) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[400], thickness: 0.5)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dateText,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[400], thickness: 0.5)),
        ],
      ),
    );
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
    messageController.dispose();
    scrollController.dispose();
    selectedAttachmentsNotifier.dispose();
    super.dispose();
  }

  void initializeChatRoom() async {
    fromId = await FirebaseRepository.getCurrentUserId() ?? '';
    setState(() {});

    // Setup scroll listener for pagination
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Check if user scrolled to the top (since list is reversed, top = oldest messages)
    // maxScrollExtent is the top of the list (oldest messages)
    if (scrollController.hasClients &&
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100) {
      // Load more messages when near the top (oldest messages)
      if (!isLoadingMore && hasMoreMessages && chatMessages.isNotEmpty) {
        _loadMoreMessages();
      }
    }
  }

  Future<void> _loadMoreMessages() async {
    if (chatMessages.isEmpty || isLoadingMore || !hasMoreMessages) {
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    try {
      // Get the oldest message timestamp (last in the list since it's reversed)
      final oldestMessage = chatMessages.last;
      final lastTimestamp = oldestMessage.sendAt ?? '';

      if (lastTimestamp.isEmpty) {
        setState(() {
          isLoadingMore = false;
          hasMoreMessages = false;
        });
        return;
      }

      // Fetch older messages
      final olderMessages = await FirebaseRepository.getOlderMessages(
        toId: toId,
        fromId: fromId,
        lastMessageTimestamp: lastTimestamp,
        limit: messagesPerPage,
      );

      if (olderMessages.isEmpty) {
        setState(() {
          isLoadingMore = false;
          hasMoreMessages = false;
        });
      } else {
        setState(() {
          // Append older messages to the end of the list
          chatMessages.addAll(olderMessages);
          isLoadingMore = false;
          hasMoreMessages = olderMessages.length >= messagesPerPage;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
      // Optionally show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more messages'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addAttachments(List<File> files) {
    final currentAttachments = selectedAttachmentsNotifier.value;
    final newAttachments = <SelectedAttachment>[];

    for (var file in files) {
      newAttachments.add(
        SelectedAttachment(
          file: file,
          id:
              '${DateTime.now().millisecondsSinceEpoch}_${currentAttachments.length + newAttachments.length}',
        ),
      );
    }

    selectedAttachmentsNotifier.value = [
      ...currentAttachments,
      ...newAttachments,
    ];
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
            Hero(
              tag:
                  'profile_${toId.isNotEmpty ? toId : argsMap?['userId'] ?? ''}',
              child: CircleAvatar(
                radius: 18,
                backgroundImage:
                    (argsMap?['profilePic'] != null &&
                            (argsMap?['profilePic'] as String).isNotEmpty)
                        ? NetworkImage(argsMap?['profilePic'])
                        : AssetImage(ImagePath.default_profile_image_2)
                            as ImageProvider,
              ),
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Chat messages
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseRepository.getChatStream(
                    toId: toId,
                    fromId: fromId,
                    limit: messagesPerPage,
                  ),
                  builder: (_, snapshot) {
                    // Update messages from stream (latest messages)
                    if (snapshot.hasData) {
                      final streamMessages =
                          snapshot.data!.docs
                              .map((d) => MessageModel.fromJson(d.data()))
                              .toList();

                      // Merge with existing messages
                      if (isInitialLoad || chatMessages.isEmpty) {
                        // First load
                        if (isInitialLoad) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                chatMessages = streamMessages;
                                hasMoreMessages =
                                    streamMessages.length >= messagesPerPage;
                                isInitialLoad = false;
                              });
                            }
                          });
                        }
                      } else {
                        // Update latest messages from stream, keep older paginated messages
                        final olderMessages =
                            chatMessages.length > messagesPerPage
                                ? chatMessages.skip(messagesPerPage).toList()
                                : <MessageModel>[];

                        // Merge: stream messages (latest) + older messages (from pagination)
                        final mergedMessages = [
                          ...streamMessages,
                          ...olderMessages,
                        ];

                        // Only update if messages changed
                        if (mergedMessages.length != chatMessages.length ||
                            mergedMessages.first.messageId !=
                                chatMessages.first.messageId) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                chatMessages = mergedMessages;
                              });
                            }
                          });
                        }
                      }
                    }

                    if (snapshot.connectionState == ConnectionState.waiting &&
                        isInitialLoad) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (chatMessages.isEmpty && !isInitialLoad) {
                      return Center(child: Text("No messages yet."));
                    }

                    return ListView.builder(
                      controller: scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: chatMessages.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (_, index) {
                        // Show loading indicator at the top when loading more
                        if (index == chatMessages.length) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final message = chatMessages[index];
                        final messageDate = getMessageDate(message.sendAt);

                        // Check if we need to show a date separator
                        // Since list is reversed (newest at bottom):
                        // - index 0 = newest message
                        // - index length-1 = oldest message
                        // Show separator if this is the first message of a new day
                        // (i.e., the next message chronologically, which is index + 1, is from a different day)
                        bool showDateSeparator = false;
                        if (index == chatMessages.length - 1) {
                          // Oldest message always shows date separator
                          showDateSeparator = true;
                        } else {
                          final nextMessage = chatMessages[index + 1];
                          final nextMessageDate = getMessageDate(
                            nextMessage.sendAt,
                          );
                          // Show separator if current message and next message are on different days
                          if (!isSameDay(messageDate, nextMessageDate)) {
                            showDateSeparator = true;
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showDateSeparator && messageDate != null)
                              _buildDateSeparator(
                                getFormattedDate(messageDate),
                              ),
                            Align(
                              alignment:
                                  message.receiverId != fromId
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child:
                                    message.receiverId == fromId
                                        ? _senderChatBox(message)
                                        : _receiverChatBox(message),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              // Selected attachments preview
              SelectedAttachmentsPreview(
                attachmentsNotifier: selectedAttachmentsNotifier,
                onRemove: (id) {
                  final currentAttachments = selectedAttachmentsNotifier.value;
                  selectedAttachmentsNotifier.value =
                      currentAttachments.where((a) => a.id != id).toList();
                },
              ),

              // Message input
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: Colors.transparent,
                child: Row(
                  children: [
                    // Attachment button (like WhatsApp paperclip)
                    IconButton(
                      icon: Icon(Icons.attach_file, color: Colors.grey[700]),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder:
                              (_) => AttachmentBottomSheet(
                                onCameraTap:
                                    () => AttachmentActions.handleCamera(
                                      context: context,
                                      onFilesSelected: (files) {
                                        _addAttachments(files);
                                      },
                                    ),
                                onGalleryTap:
                                    () => AttachmentActions.handleGallery(
                                      context: context,
                                      onFilesSelected: (files) {
                                        _addAttachments(files);
                                      },
                                    ),
                                onDocumentTap:
                                    () => AttachmentActions.handleDocument(
                                      context: context,
                                      onFileSelected: (file) {
                                        _addAttachments([file]);
                                      },
                                    ),
                                onAudioTap:
                                    () => AttachmentActions.handleAudio(
                                      context: context,
                                    ),
                                onLocationTap:
                                    () => AttachmentActions.handleLocation(
                                      context: context,
                                    ),
                                onContactTap:
                                    () => AttachmentActions.handleContact(
                                      context: context,
                                    ),
                              ),
                        );
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: messageController,
                        validator:
                            (value) =>
                                value!.isEmpty ? "Message is required" : null,
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
                    // Voice message send button
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: IconButton(
                        icon: Icon(Icons.mic, color: Colors.black87),
                        onPressed: () {
                          // TODO: start / stop voice recording and send audio message
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    // Text send button
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          if (toId != '') {
                            final attachments =
                                selectedAttachmentsNotifier.value;

                            if (attachments.isNotEmpty) {
                              // Get all image file paths and join with comma
                              final imageUrls = attachments
                                  .map((a) => a.file.path)
                                  .join(',');

                              FirebaseRepository.sendImage(
                                imageUrl: imageUrls,
                                toId: toId,
                                message:
                                    messageController.text.isEmpty
                                        ? ''
                                        : messageController.text,
                              );

                              // Clear attachments after sending
                              selectedAttachmentsNotifier.value = [];
                            } else if (messageController.text.isNotEmpty) {
                              // Send text only message
                              FirebaseRepository.sendTextMessage(
                                toId: toId,
                                message: messageController.text,
                              );
                            }

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
      ),
    );
  }

  // left side chat box (receiver)
  Widget _receiverChatBox(MessageModel message) {
    final imageUrls = message.getImageUrls();
    final hasImages = imageUrls.isNotEmpty;
    final hasText = message.message != null && message.message!.isNotEmpty;

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
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text only message
          if (message.messageType == 0)
            Text(
              message.message ?? '',
              style: TextStyle(color: Colors.black, fontSize: 16),
            )
          // Image with or without text
          else if (hasImages)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ImageGridWidget(
                  imageUrls: imageUrls,
                  maxWidth: 250,
                  onImageTap: (index) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => ImageViewer(
                              imageUrls: imageUrls,
                              initialIndex: index,
                            ),
                      ),
                    );
                  },
                ),
                if (hasText) ...[
                  SizedBox(height: 8),
                  Text(
                    message.message ?? '',
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ],
              ],
            ),
          SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                getFormattedTime(message.sendAt),
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.done_all_rounded,
                size: 16,
                color: message.readAt != "" ? Colors.blue : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // right side chat box (sender)
  Widget _senderChatBox(MessageModel message) {
    // Update read status
    if (message.readAt == "") {
      FirebaseRepository.updateReadStatus(
        toId: toId,
        fromId: fromId,
        messageId: message.messageId ?? '',
      );
    }

    final imageUrls = message.getImageUrls();
    final hasImages = imageUrls.isNotEmpty;
    final hasText = message.message != null && message.message!.isNotEmpty;

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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text only message
          if (message.messageType == 0)
            Text(
              message.message ?? '',
              style: TextStyle(color: Colors.black, fontSize: 15),
            )
          // Image with or without text
          else if (hasImages)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ImageGridWidget(
                  imageUrls: imageUrls,
                  maxWidth: 250,
                  onImageTap: (index) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => ImageViewer(
                              imageUrls: imageUrls,
                              initialIndex: index,
                            ),
                      ),
                    );
                  },
                ),
                if (hasText) ...[
                  SizedBox(height: 8),
                  Text(
                    message.message ?? '',
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ],
              ],
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
