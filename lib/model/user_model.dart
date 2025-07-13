class UserModel{
  String? userId;
  String? name;
  String? email;
  String? phoneNo;
  String? createdAt;
  bool isOnline = false;
  int? status = 1; // 1 -> Active , 2 -> Inactive, 3 -> Suspended
  String? profilePic = "";
  int? profileStatus = 1;

  UserModel({this.userId, this.name, this.email, this.phoneNo,
    this.createdAt, required this.isOnline, this.status, this.profilePic,
    this.profileStatus});

  factory UserModel.fromDoc(Map<String, dynamic> doc){
    return UserModel(name: doc['name'], email: doc['email'], phoneNo: doc['phoneNo'], createdAt: doc['createdAt'], isOnline: doc['isOnline'], status: doc['status'], profilePic: doc['profilePic'], profileStatus: doc['profileStatus']);
  }

  Map<String, dynamic> toDoc() => {
    "name" : name,
    "email" : email,
    "phoneNo" : phoneNo,
    "createdAt" : createdAt,
    "isOnline" : isOnline,
    "status" : status,
    "profilePic" : profilePic,
    "profileStatus" : profileStatus
  };
}