import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_journal_app/models/journal_entry_model.dart';
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

  Stream<List<JournalEntry>> getEntries(String userId) {
    return _db
        .collection('entries')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => JournalEntry.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addEntry({
    required String userId,
    required String title,
    required String content,
    String? imageUrl,
  }) {
    return _db.collection('entries').add({
      'userId': userId,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> deleteEntry(String entryId) {
    return _db.collection('entries').doc(entryId).delete();
  }
}
