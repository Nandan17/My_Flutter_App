import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable //it is an annotation any class any subclasses of this will be immutable
class AuthUser {
  final String id;
  final String email;
  final bool isEmailVarified;
   //constructor
  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVarified,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
    id: user.uid,
    email: user.email!,
    isEmailVarified: user.emailVerified,
    );

  //void testing() {
    //AuthUser(isEmailVarified:true);
  //}
}

