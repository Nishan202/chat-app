import 'package:chat_app/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/user_model.dart';

class FirebaseRepository {
  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  static const String collectionUsers = "users";
  static const String collectionChatroom = "chatroom";
  static const String collectionMessages = "messages";
  static const String idsField = "ids";
  static const String prefsUserId = "userId";

  Future<void> createUser({
    required UserModel user,
    required String password,
  }) async {
    try {
      var userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: user.email!,
        password: password,
      );
      if (userCredential.user != null) {
        user.userId = userCredential.user!.uid;
        firebaseFirestore
            .collection(collectionUsers)
            .doc(userCredential.user!.uid)
            .set(user.toDoc())
            .catchError((error) {
              throw (Exception("Error : $error"));
            });
      }
    } on FirebaseAuthException catch (e) {
      throw (Exception("Error : ${e.message}"));
    } catch (e) {
      throw (Exception("Error : $e"));
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      var userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        // add user id in preference
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(prefsUserId, userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      throw (Exception("Error : ${e.message}"));
    } catch (e) {
      throw (Exception("Error : $e"));
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getAllContacts() async {
    return await firebaseFirestore.collection(collectionUsers).get();
  }

  static Future<String?> getCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(prefsUserId);
  }

  static String getChatId({required String fromId, required String toId}) {
    // String chatId;
    if (fromId.hashCode <= toId.hashCode) {
      return '${fromId}_$toId';
    } else {
      return '${toId}_$fromId';
    }
    // return chatId;
  }

  static sendTextMessage({
    required String toId,
    required String message,
  }) async {
    String? fromId = await getCurrentUserId();
    String? chatId = getChatId(fromId: fromId ?? '', toId: toId);
    String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    MessageModel messageModel = MessageModel(
      messageId: currentTime,
      message: message,
      receiverId: toId,
      senderId: fromId,
      sendAt: currentTime,
    );

    await firebaseFirestore.collection(collectionChatroom).doc(chatId).set({
      idsField: [fromId, toId],
    }, SetOptions(merge: true));
    await firebaseFirestore
        .collection(collectionChatroom)
        .doc(chatId)
        .collection(collectionMessages)
        .doc(currentTime)
        .set(messageModel.toJson())
        .catchError((error) {
          throw (Exception("Error : $error"));
        });
  }

  static sendImage({
    required String toId,
    String message = '',
    required String imageUrl,
  }) async {
    String? fromId = await getCurrentUserId();
    String? chatId = getChatId(fromId: fromId ?? '', toId: toId);
    String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    MessageModel messageModel = MessageModel(
      messageId: currentTime,
      message: message,
      imageUrl: imageUrl,
      receiverId: toId,
      senderId: fromId,
      sendAt: currentTime,
      messageType: 1,
    );
    await firebaseFirestore.collection(collectionChatroom).doc(chatId).set({
      idsField: [fromId, toId],
    }, SetOptions(merge: true));
    await firebaseFirestore
        .collection(collectionChatroom)
        .doc(chatId)
        .collection(collectionMessages)
        .doc(currentTime)
        .set(messageModel.toJson())
        .catchError((error) {
          throw (Exception("Error : $error"));
        });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getChatStream({
    required String toId,
    required String fromId,
  }) {
    String chatId = getChatId(fromId: fromId, toId: toId);
    return firebaseFirestore
        .collection(collectionChatroom)
        .doc(chatId)
        .collection(collectionMessages)
        .orderBy('sendAt', descending: false)
        .snapshots();
  }

  static Future<List<MessageModel>> getAllMessages({
    required String toId,
    required String fromId,
  }) async {
    String chatId = getChatId(fromId: fromId, toId: toId);
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firebaseFirestore
            .collection(collectionChatroom)
            .doc(chatId)
            .collection(collectionMessages)
            .orderBy('sendAt', descending: false)
            .get();

    return querySnapshot.docs
        .map((doc) => MessageModel.fromJson(doc.data()))
        .toList();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLiveChatContactStream({
    required String fromId,
  }) {
    return firebaseFirestore
        .collection(collectionChatroom)
        .where("ids", arrayContains: fromId)
        .snapshots();
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfoById({
    required String userId,
  }) async {
    return await firebaseFirestore
        .collection(collectionUsers)
        .doc(userId)
        .get();
  }

  static void updateReadStatus({
    required String toId,
    required String fromId,
    required String messageId,
  }) async {
    String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    // String? fromId = await getCurrentUserId();
    String chatId = getChatId(fromId: fromId, toId: toId);

    await firebaseFirestore
        .collection(collectionChatroom)
        .doc(chatId)
        .collection(collectionMessages)
        .doc(messageId)
        .update({'readAt': currentTime})
        .catchError((error) {
          throw (Exception("Error : $error"));
        });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage({
    required String toId,
    required String fromId,
  }) {
    String chatId = getChatId(fromId: fromId, toId: toId);
    return firebaseFirestore
        .collection(collectionChatroom)
        .doc(chatId)
        .collection(collectionMessages)
        .orderBy('sendAt', descending: true)
        .limit(1)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUnreadMessageCount({
    required String toId,
    required String fromId,
  }) {
    String chatId = getChatId(fromId: fromId, toId: toId);
    return firebaseFirestore
        .collection(collectionChatroom)
        .doc(chatId)
        .collection(collectionMessages)
        .where("readAt", isEqualTo: "")
        .where('senderId', isEqualTo: toId)
        .snapshots();
  }

  static Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefsUserId);
    await firebaseAuth.signOut();
  }
}
