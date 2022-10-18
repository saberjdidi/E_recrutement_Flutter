import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/user_model.dart';

class FirebaseApi {

   getUsers(searchQuery) => FirebaseFirestore.instance
      .collection('users')
      .where('name', isGreaterThanOrEqualTo: searchQuery)
      .snapshots();
}