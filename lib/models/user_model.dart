//this is a blue print or model of a user this is how a user should be
class UserModel {
  final String uid;
  final String name;
  final String email;

  UserModel({required this.uid, required this.name, required this.email});
//converting it to map (key value) to use it in firebase format
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name':name,
      'email':email,
    };
  }
}
