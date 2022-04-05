import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';


class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({ Key? key }) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {//previously every time we do hot reload a new note will be created to avoid that we will create _note to keep track of existing notes
  CloudNote? _note;//it will keep hold of our current note in new_note_view.dart
  //_notesService is of type FirebaseCloudstorage
  late final FirebaseCloudStorage _notesService; //keep reference to NotesService
  late final TextEditingController _textController; //this is to track text changes

  @override
  void initState(){
    _notesService = FirebaseCloudStorage();
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
      documentId: note.documentId, 
      text: text,
      );
  }

  //hook our text field changes to the listener
  void _setupTextControllerListener(){
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {//check for if the note is already exist if yes return the existing note else create a new notwe
    
    //we need a generic way of extracting arguments from the BuildContext
    final widgetNote = context.getArgument<CloudNote>();   

    if(widgetNote != null){//in update note we need to populate with pre existing information
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if(existingNote != null){
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  //Upon disposal, we need to delete the note if text is empty
  void _deleteNoteIfTextIsEmpty(){//if the user presses + button but enters nothing and goes back there shoulldn't be any empty note created.
    final note = _note;
    if(_textController.text.isEmpty && note != null){
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  //save the note if text is not empty
  void _saveNoteIfNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if(note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        documentId: note.documentId, 
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
        title: const Text('new Note'),
        actions: [
          IconButton(
            onPressed: () async{
              final text = _textController.text;
              if(_note == null || text.isEmpty) {
                  await showCannotShareEmptyNoteDialog(context);
              } else {
                Share.share(text);
              }
            }, 
            icon: const Icon(Icons.share),
            )
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),//this function gets called
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.done:
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