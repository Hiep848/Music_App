import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // sign in
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      // sign user in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );

      // save user info if it doeasn't exist
      _firestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
        },
      );

      return userCredential;  
  } on FirebaseAuthException catch (e) {
    throw Exception(e.code);
    }
  }
  // sign up
  Future<UserCredential> signUpWithEmailPassword(String email, password) async {
    try {
      // create user
      UserCredential userCredential = 
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

      // save user info in a separate doc
      _firestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
        },
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
  // delete user
  Future<void> deleteUser() async {
    try {
      final String userId = _auth.currentUser!.uid;

      //  Xóa document của user trong collection Users
      await _firestore.collection("Users").doc(userId).delete();

      //  Cuối cùng mới xóa user trong Authentication
      await _auth.currentUser!.delete();
      
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
  // sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
}