import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/services/remote/firebase_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contacts")),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseRepository.getAllContacts(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (_, index) {
                var currentModel = UserModel.fromDoc(
                  snapshot.data!.docs[index].data(),
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(currentModel.name ?? ""),
                        subtitle: Text(currentModel.email ?? ""),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            currentModel.profilePic ?? "",
                          ),
                        ),
                        trailing: Icon(Icons.chat),
                        onTap: () {},
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Center(child: Text("No data found"));
        },
      ),
    );
  }
}
