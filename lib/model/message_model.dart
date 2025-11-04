class MessageModel {
  final String? message;
  final String? senderId;
  final String? receiverId;
  final String? readAt;
  final String? messageId;
  final String? sendAt;
  // final String? receivedAt;
  final int? messageType;
  final String? imageUrl;

  MessageModel({
    this.message,
    this.senderId,
    this.receiverId,
    this.messageId,
    this.sendAt,
    // this.receivedAt = "",
    this.readAt = "",
    this.messageType = 0,
    this.imageUrl = "",
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      message: json['message'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      messageId: json['messageId'],
      sendAt: json['sendAt'],
      // receivedAt: json['receivedAt'],
      readAt: json['readAt'],
      messageType: json['messageType'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'senderId': senderId,
      'receiverId': receiverId,
      'messageId': messageId,
      'sendAt': sendAt,
      // 'receivedAt': receivedAt,
      'readAt': readAt,
      'messageType': messageType,
      'imageUrl': imageUrl,
    };
  }
}
