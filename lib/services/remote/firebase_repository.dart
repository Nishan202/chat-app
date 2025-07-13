import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/user_model.dart';

class FirebaseRepository {
  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  static const String COLLECTION_USERS = "users";
  static const String COLLECTION_CHATROOM = "chatroom";
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
}
