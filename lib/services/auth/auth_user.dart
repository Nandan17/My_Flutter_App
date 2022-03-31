import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable //it is an annotation any class any subclasses of this will be immutable
class AuthUser {
  final String? email;
  final bool isEmailVarified;
   //constructor
  const AuthUser({
    required this.email,
    required this.isEmailVarified,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
    email: user.email,
    isEmailVarified: user.emailVerified,
    );

  //void testing() {
    //AuthUser(isEmailVarified:true);
  //}
}

