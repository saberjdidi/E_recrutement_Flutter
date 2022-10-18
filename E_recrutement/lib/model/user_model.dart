import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String? id;
  String? name;
  String? email;
  String? location;
  String? phoneNumber;
  String? userImage;
  Timestamp? createdAt;

   User({
    this.id,
    this.name,
    this.email,
    this.location,
     this.phoneNumber,
     this.userImage,
     this.createdAt,

  });


  /*static User fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    location: json['location'],
    phoneNumber: json['phoneNumber'],
    userImage: json['userImage'],
    createdAt: json['createdAt'],
  );*/
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      location: json['location'],
      phoneNumber: json['phoneNumber'],
      userImage: json['userImage'],
      createdAt: json['createdAt']
    );
    /*id = json['id'];
    name = json['name'];
    email = json['email'];
    location = json['location'];
    phoneNumber = json['phoneNumber'];
    userImage = json['userImage'];
    createdAt = json['createdAt']; */
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'location': location,
    'phoneNumber': phoneNumber,
    'userImage': userImage,
    'createdAt': createdAt,
  };
}