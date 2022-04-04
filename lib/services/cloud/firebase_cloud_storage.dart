import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  
  //grab all notes
  final notes = FirebaseFirestore.instance.collection('notes');
  
  //delete the document
  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  //update the existing notes
  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  //all notes for a specific user
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    final allNotes = notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));
    return allNotes;
  }

  //Getting notes by user ID
  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try{
      return await notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .get()
        .then(
          (value) => value.docs.map(
            (doc) {
              return CloudNote(
                documentId: doc.id, 
                ownerUserId: doc.data()[ownerUserIdFieldName] as String, 
                text: doc.data()[textFieldName] as String,
                );
            },
          ),
        );
    }catch (e){
      throw CouldNotGetAllNotesException();
    }
  }

  //creating new notes
  void createNewNote({required String ownerUserId}) async {
      await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }

  //make firebase cloudstorage singleton
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}