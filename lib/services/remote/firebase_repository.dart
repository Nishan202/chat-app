import 'package:chat_app/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/user_model.dart';

class FirebaseRepository {
  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  static const String COLLECTION_USERS = "users";
  static const String COLLECTION_CHATROOM = "chatroom";
  static const String COLLECTION_MESSAGES = "messages";
  static const String IDS_FIELD = "ids";
  static const String PREFS_USER_ID = "userId";

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
            .collection(COLLECTION_USERS)
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
        prefs.setString(PREFS_USER_ID, userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      throw (Exception("Error : ${e.message}"));
    } catch (e) {
      throw (Exception("Error : $e"));
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getAllContacts() async {
    return await firebaseFirestore.collection(COLLECTION_USERS).get();
  }

  static Future<String?> getCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PREFS_USER_ID);
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

    await firebaseFirestore.collection(COLLECTION_CHATROOM).doc(chatId).set({
      IDS_FIELD: [fromId, toId],
    }, SetOptions(merge: true));
    await firebaseFirestore
        .collection(COLLECTION_CHATROOM)
        .doc(chatId)
        .collection(COLLECTION_MESSAGES)
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
    await firebaseFirestore.collection(COLLECTION_CHATROOM).doc(chatId).set({
      IDS_FIELD: [fromId, toId],
    }, SetOptions(merge: true));
    await firebaseFirestore
        .collection(COLLECTION_CHATROOM)
        .doc(chatId)
        .collection(COLLECTION_MESSAGES)
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
        .collection(COLLECTION_CHATROOM)
        .doc(chatId)
        .collection(COLLECTION_MESSAGES)
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
            .collection(COLLECTION_CHATROOM)
            .doc(chatId)
            .collection(COLLECTION_MESSAGES)
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
        .collection(COLLECTION_CHATROOM)
        .where("ids", arrayContains: fromId)
        .snapshots();
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfoById({
    required String userId,
  }) async {
    return await firebaseFirestore
        .collection(COLLECTION_USERS)
        .doc(userId)
        .get();
  }

  static Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(PREFS_USER_ID);
    await firebaseAuth.signOut();
  }
}
