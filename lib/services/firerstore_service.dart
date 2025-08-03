import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_journal_app/models/user_model.dart';

class FirerstoreService {
  //we are connecting to firestore with variable _db to use it here
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //creating a methoda to add user in firestore UserModel is the type and user is the variable name
  Future<void> addUser(UserModel user) {
    //got to collection named users
    //create a document unique user id
    //save the data from usermodel as to map methoda
    return _db.collection('users').doc(user.uid).set(user.toMap());
  }
}
