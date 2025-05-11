class UserModel{
  String? userId;
  String? name;
  String? email;
  String? password;
  String? phoneNo;
  String? createdAt;
  bool isOnline = false;
  int? status = 1; // 1 -> Active , 2 -> Inactive, 3 -> Suspended
  String? profilePic = "";
  int? profileStatus = 1;

  UserModel({this.userId, required this.name, required this.email, required this.password, required this.phoneNo,
    required this.createdAt, required this.isOnline, required this.status, required this.profilePic,
    required this.profileStatus});

  factory UserModel.fromDoc(Map<String, dynamic> doc){
    return UserModel(name: doc['name'], email: doc['email'], password: doc['password'], phoneNo: doc['phoneNo'], createdAt: doc['createdAt'], isOnline: doc['isOnline'], status: doc['status'], profilePic: doc['profilePic'], profileStatus: doc['profileStatus']);
  }

  Map<String, dynamic> toDoc() => {
    "name" : name,
    "email" : email,
    "password" : password,
    "phoneNo" : phoneNo,
    "createdAt" : createdAt,
    "isOnline" : isOnline,
    "status" : status,
    "profilePic" : profilePic,
    "profileStatus" : profileStatus
  };
}