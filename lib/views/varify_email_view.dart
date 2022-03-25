import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VarifyEmailView extends StatefulWidget {
  const VarifyEmailView({ Key? key }) : super(key: key);

  @override
  State<VarifyEmailView> createState() => _VarifyEmailViewState();
}

class _VarifyEmailViewState extends State<VarifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Varify the email'),),
      body: Column(
        children: [
          const Text('Please Varify your email address'),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              user?.sendEmailVerification();
              },
              child:const Text('Send email varification'),
           )
        ],
      ),
    );
  }
}