import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart.dart';
import 'package:mynotes/views/notes/notes_view.dart';
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
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        varifyEmailRoute:(context) => const VarifyEmailView(),
        CreateOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
     ),
  );
}


// class Homepage extends StatelessWidget {
//   const Homepage({ Key? key }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future:  AuthService.firebase().initialize(),
//         builder: (context, snapshot) {
//            switch (snapshot.connectionState){
//              case ConnectionState.done:
//                 final user = AuthService.firebase().currentUser;
//                 if(user != null){
//                   //these are the lines to uncomment
//                   if(user.isEmailVarified){
//                      devtools.log('email varified');
//                      return const NotesView();
//                    }else{
//                      return const VarifyEmailView();
//                    }
//                 }else{
//                     return const LoginView();
//                 }
//                 //return const NotesView();
//           //       print(user);
//           //       if(user?.emailVerified ?? false){
//           //         return const Text('Done');
//           //       }else{
//           //         return const VarifyEmailView();
//           //       }
                  
//                default:
//                   return const CircularProgressIndicator();
//           }
          
//         },
        
//       );
//   }
// }

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _controller;

  @override
  void initState(){
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose(){
    _controller.dispose();
    super.initState();
  }

  //Use Bloc to create our main UI
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(

        appBar: AppBar(
          title: const Text('Tesing Bloc'),
          ),

        body: BlocConsumer<CounterBloc, CounterState>( //blocconsumer is a combination of bloclistener and blocbuilder

            listener: (context, state) {//everytime we pressed + button or - button we need to clear the textfield
              _controller.clear(); //upon any new state is produced by bloc we need to clear controller
            },

            builder: (context, state) {
              final invalidValue = 
                  (state is CounterStateInvalidNumber) ? state.invalidValue: '';
                  return Column(
                    children: [
                      Text('Current value => ${state.value}'),

                      Visibility(
                        child: Text('Invalid input: $invalidValue'),
                        visible: state is CounterStateInvalidNumber,
                      ),
                      
                      TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Enter a number here',
                        ),
                        keyboardType: TextInputType.number,
                      )
                    ],
                  );
                },
              )
            ),
          );
  }
}

//event is something go inside and state is something that come outside
//We divide our state into valid state and invalid state

//valid state
//class CouterStateValid extends CounterState
@immutable
abstract class CounterState{ //basic state of the bloc
  final int value;
  const CounterState(this.value);//constructor
}

//2 substates of the state
//1st substate when user enters a valid state
class CounterStateValid extends CounterState {
  const CounterStateValid(int value) : super(value);//give me a value i will call super class with that value
}


//when user enters invalid value
class CounterStateInvalidNumber extends CounterState {
  final String invalidValue;
  const CounterStateInvalidNumber({
    required this.invalidValue,
    required int previousValue,
  }) : super(previousValue);
}

//string that comes from UI goes directly into event
@immutable
abstract class CounterEvent {
  final String value;
  const CounterEvent(this.value);
}

//2 events
class IncrementEvent extends CounterEvent {
  const IncrementEvent(String value) : super(value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(String value) : super(value);
}

//we need to pack this event with user entered string value and send it to the bloc

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)){ //CounterBloc() is constructor it calls super to intitialize to 0
    on<IncrementEvent>((event, emit) {
      final integer = int.tryParse(event.value);//try to parse to given string and make it to integer
      if(integer == null){//couldn't parse it to integer
        emit(CounterStateInvalidNumber(
          invalidValue: event.value, 
          previousValue: state.value,
          ),
        );
      } else {
        emit(CounterStateValid(state.value + integer)
        );
      }
    });
    on<DecrementEvent>((event, emit) {
      final integer = int.tryParse(event.value);
      if(integer == null){
        emit(CounterStateInvalidNumber(
          invalidValue: event.value, 
          previousValue: state.value,
          ),
        );
      } else {
        emit(CounterStateValid(state.value - integer)
        );
      }
    });
  }
}