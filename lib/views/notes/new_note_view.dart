import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({ Key? key }) : super(key: key);

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {//previously every time we do hot reload a new note will be created to avoid that we will create _note to keep track of existing notes
  DatabaseNote? _note;//it will keep hold of our current note in new_note_view.dart
  late final NotesService _notesService; //keep reference to NotesService
  late final TextEditingController _textController; //this is to track text changes

  @override
  void initState(){
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  //update our current note upon text changes
  void _textControllerListener() async {
    final note = _note;
    if(note == null){
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(
      note: note, 
      text: text,
      );
  }

  //hook our text field changes to the listener
  void _setupTextControllerListener(){
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createNewNote() async {//check for if the note is already exist if yes return the existing note else create a new notwe
    final existingNote = _note;
    if(existingNote != null){
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser;
    final email = currentUser!.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
  }

  //Upon disposal, we need to delete the note if text is empty
  void _deleteNoteIfTextIsEmpty(){//if the user presses + button but enters nothing and goes back there shoulldn't be any empty note created.
    final note = _note;
    if(_textController.text.isEmpty && note != null){
      _notesService.deleteNote(id: note.id);
    }
  }

  //save the note if text is not empty
  void _saveNoteIfNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if(note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        note: note, 
        text: text,
        );
    }
  }

  @override
  void dispose(){
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('new Note')
      ),
      body: FutureBuilder(
        future: createNewNote(),//this function gets called
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote;
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing your note...',
                ),
              );
              default:
                return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}