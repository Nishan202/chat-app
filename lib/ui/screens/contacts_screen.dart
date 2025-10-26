import 'package:chat_app/constant/image_path.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/services/remote/firebase_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
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
      appBar: AppBar(title: Text("Contacts")),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseRepository.getAllContacts(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            List<UserModel> listContacts = List.generate(
              snapshot.data!.docs.length,
              (index) => UserModel.fromDoc(snapshot.data!.docs[index].data()),
            );

            listContacts.removeWhere((element) => element.userId == fromId);
            return ListView.builder(
              itemCount: listContacts.length,
              itemBuilder: (_, index) {
                UserModel currentModel = listContacts[index];
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
                          backgroundImage:
                              currentModel.profilePic != ""
                                  ? NetworkImage(currentModel.profilePic ?? '')
                                  : AssetImage(
                                        ImagePath.default_profile_image_2,
                                      )
                                      as ImageProvider,
                        ),
                        trailing: Icon(Icons.chat),
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.CHAT_SCREEN,
                              arguments: {
                                'name': currentModel.name,
                                'profilePic': currentModel.profilePic,
                                'userId': currentModel.userId,
                              },
                            ),
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
