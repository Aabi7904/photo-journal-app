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

  // NOW WE GONNA CREATE THREE METHODS
  // 1. to get the entries from firestore(we will use this method in homepage to show the ui)
  //2. to add and save to firestore(use in add entry page when click saved thi method is called and entry saved to firestore) 
  //3. delete entry from firestore

  // here we uses stream to get live updates
  //list type and jornal entry model
  //return form _db using collection entries
  //using where will get the specific user id
  //snapshot will have the data
  //creating it as a jornal entry model object and making it as a list type
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

  //this is to add the entry and save to firebase
  //it will add all the entries to the 'entries' collection 

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
