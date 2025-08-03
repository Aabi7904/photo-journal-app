import 'package:firebase_auth/firebase_auth.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_journal_app/models/user_model.dart';
import 'package:photo_journal_app/services/firerstore_service.dart';

class AUthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirerstoreService _firerstoreService = FirerstoreService();

  //sign with email and pass
  //creating a methoda for email and pass signin
  //that returns a user object
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      //usercredential is a inbuilt method and using that we save users data in result
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      //it will return the result to user object
      //user is a property from User?
      return result.user;
      //if any error it will catch and save it in e
    } on FirebaseAuthException catch (e) {
      showToast(
        //if no error message from firebase it shows default message
        e.message ?? "An error occured",
        position: ToastPosition.bottom,
      );
      return null;
    }
  }

  Future<User?> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      //we are saving the user credentials from result.user to the "user"
      User? user = result.user;

      if (user != null) {
        UserModel newUser = UserModel(uid: user.uid, name: name, email: email);
        await _firerstoreService.addUser(newUser);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      showToast(
        e.message ?? "an error occured",
        position: ToastPosition.bottom,
      );
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
