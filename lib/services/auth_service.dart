import 'package:firebase_auth/firebase_auth.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_journal_app/models/user_model.dart';
import 'package:photo_journal_app/services/firerstore_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AUthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirerstoreService _firerstoreService = FirerstoreService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
  //sign in with google method

  Future<User?> signInWithGoogle() async {
    try {
      //this will give google accounts choosing pop window
      //stores chosen account info in googleUser
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      //if we choose none or came back it will return null
      if (googleUser == null) {
        return null;
      }
      //here we are getting authentication tokens from google to firebase
      //so that firebase can trust u
      //acces token: prrof u signed in
      //idtoken : info about u
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      //here we are converting google tokens to firebase form token to use it in
      //using googleauthprovider we do this
      //this is called oauthcredential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      //now we are login to firebase using that credential
      //usercredential will have user details and whether uer is new or old
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      //here only we are getting the actual user object 
      User? user = userCredential.user;
      //now we check user is new or existing if new means
      //using our user model we save to firebase
      if (user != null && userCredential.additionalUserInfo!.isNewUser) {
        UserModel newUser = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'Google User',
          email: user.email!,
        );
        //here we save the new user to firestore
        await _firerstoreService.addUser(newUser);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      showToast(
        e.message ?? "An error occured",
        position: ToastPosition.bottom,
      );
      return null;
    }
  }
  //register with email and pass

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
//signout method
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
