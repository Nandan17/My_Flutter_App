import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable //it is an annotation any class any subclasses of this will be immutable
class AuthUser {
  final bool isEmailVarified;

  const AuthUser(this.isEmailVarified);

  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}

