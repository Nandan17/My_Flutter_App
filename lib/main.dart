
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/login_view.dart';
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
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView()
      },
     ),
  );
}


class Homepage extends StatelessWidget {
  const Homepage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:  Firebase.initializeApp(
                  options: DefaultFirebaseOptions.currentPlatform,
                ),
        builder: (context, snapshot) {
           switch (snapshot.connectionState){
             case ConnectionState.done:
                final user = FirebaseAuth.instance.currentUser;
                if(user != null){
                  //these are the lines to uncomment
                  // if(user.emailVerified){
                  //   print('email varified');
                  //   return const NotesView();
                  // }else{
                  //   return const VarifyEmailView();
                  // }
                }else{
                    return const LoginView();
                }
                return const NotesView();
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

enum MenuAction { logout }


class NotesView extends StatefulWidget {
  const NotesView({ Key? key }) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async{
              switch (value) {
                
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  //logout from firebase
                  if(shouldLogout){
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login/',
                       (_) => false,
                       );
                  }
                  //devtools.log(shouldLogout.toString());
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text('Log out'),
              ),
              ];

              
            },)
        ],
      ),
      body: const Text('Hello World'),
    );
  }
}


Future<bool> showLogOutDialog(BuildContext context){
    return showDialog<bool>(context: context, 
    builder: (context){
      return AlertDialog(
          title: const Text('Sign out'),
          content: const Text('Are you sure want to sign out'),
          actions: [
            TextButton(onPressed:() {
              Navigator.of(context).pop(false);
            }, child: const Text('Cancel')
            ),
            TextButton(onPressed:() {
              Navigator.of(context).pop(true);
            }, child: const Text('Log Out')
            )
          ],
      );
    },
    ).then((value) => value ?? false);
}

//creating a stateless widget
//scaffold - a basic building block we need a scaffold inside our Homepage widget


/*class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        
        title: Text(widget.title),
      ),
      body: Center(
        
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}*/
