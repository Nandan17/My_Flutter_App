import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

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
          const Text('We\'ve sent to you an email varification. Please oprn it to varify your account'),
          const Text('If you haven\'t received a varification email yet, press the button below'),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
              },
              child:const Text('Send email varification'),
           ),
           TextButton(
             onPressed: () async {
               await AuthService.firebase().logout();
               Navigator.of(context).pushNamedAndRemoveUntil(
                 registerRoute,
                 (route) => false,
                 );
             },
             child: const Text("Restart"),
             )
        ],
      ),
    );
  }
}