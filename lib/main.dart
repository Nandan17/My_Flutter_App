import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/varify_email_view.dart';
import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
     MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Homepage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        varifyEmailRoute:(context) => const VarifyEmailView(),
      },
     ),
  );
}


class Homepage extends StatelessWidget {
  const Homepage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:  AuthService.firebase().initialize(),
        builder: (context, snapshot) {
           switch (snapshot.connectionState){
             case ConnectionState.done:
                final user = AuthService.firebase().currentUser;
                if(user != null){
                  //these are the lines to uncomment
                  if(user.isEmailVarified){
                     devtools.log('email varified');
                     return const NotesView();
                   }else{
                     return const VarifyEmailView();
                   }
                }else{
                    return const LoginView();
                }
                //return const NotesView();
          //       print(user);
          //       if(user?.emailVerified ?? false){
          //         return const Text('Done');
          //       }else{
          //         return const VarifyEmailView();
          //       }
                  
               default:
                  return const CircularProgressIndicator();
          }
          
        },
        
      );
  }
}




