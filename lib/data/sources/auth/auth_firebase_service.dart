import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:music_app/data/models/auth/create_user_req.dart';
import 'package:music_app/data/models/auth/signin_user_req.dart';

abstract class AuthFirebaseService {

  Future<Either> signup(CreateUserReq createUserReq);

  Future<Either> signin(SigninUserReq signinUserReq);

}

class AuthFirebaseServiceImpl extends AuthFirebaseService{
  @override
  Future<Either> signin(SigninUserReq signinUserReq) async {
    try {

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: signinUserReq.email,
        password: signinUserReq.password,
      );

      return Right('Signin was succesful');

    } on FirebaseAuthException catch(e) {
      String? message = '';
      switch (e.code) {
        case 'invalid-email':
          message = 'No user found for that email address';
          break;
        case 'invalid-credential':
          message = 'Wrong password provided for that user';
          break;
        default:
          message = e.message;
      }
      return Left(message);
    }
  }

  @override
  Future<Either> signup(CreateUserReq createUserReq) async {
    try {

      var data = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: createUserReq.email,
        password: createUserReq.password,
      );

      FirebaseFirestore.instance.collection('Users').add(
        {
          'name': createUserReq.fullName,
          'email': data.user?.email,
        }
      );

      return const Right('Signup was succesful');

    } on FirebaseAuthException catch(e) {
      String message = '';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email already in use';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'weak-password':
          message = 'Weak password';
          break;
        default:
          message = 'An unknown error occurred';
      }
      return Left(message);
    }
  }

}