import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;




class NotesService {
  Database? _db; //our local database

  //each time when we need the list of all notes we need to access the database rather than that we can maintain a list of all notes 
  List<DatabaseNote> _notes = [];

  //Make NotesService singleton
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance();
  factory NotesService() => _shared;

  //streamcontroller acts as an interface between UI and notesview
  final _notesStreamController = 
          StreamController<List<DatabaseNote>>.broadcast();


  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  //get the user from the database if user doesnot exists create that user
  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try{
        final user = await getUser(email: email);
        return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  //read the data from database and put that in both _notes and _notesSTreamController
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  //update the note
  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //make sure note exists
    await getNote(id: note.id);

    //update db
    final updateCount = await db.update(noteTable, { //returns no of rows updated
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if(updateCount == 0){
      throw CouldNotUpdateNote();
    }else{
      //update the cache in updateNote
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  //fetching all notes
  Future<Iterable<DatabaseNote>> getAllNotes () async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
    );

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  //Fetching a specific note
  Future<DatabaseNote> getNote ({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if(notes.isEmpty){
      throw CouldNotFindNote();
    }else{
      //remove old note with same id and add the new one and update stream
      //this is actually we are updating cache
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }

  }

  //delete all notes
  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions =  await db.delete(noteTable);//return no of rows affected
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
  }

  //allow noted to be deleted
  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if(deletedCount == 0){
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  //Allow creation of new notes
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //make sure owner exists in the database with correct id
    final dbUser = await getUser(email: owner.email);
    if(dbUser != owner){
      throw CouldNotFindUser();
    }
    const text = '';
    //create the note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNote(
      id: noteId, 
      userId: owner.id, 
      text: text, 
      isSyncedWithCloud: true
      );

      _notes.add(note);
      _notesStreamController.add(_notes);

      return note;
    }

  //To fetch the user
  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable, 
      limit: 1, 
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      );
      if(results.isEmpty) {
        throw CouldNotFindUser();
      } else{
        return DatabaseUser.fromRow(results.first);
      }
  }

  //allow create a user
  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable, 
      limit: 1, 
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      );

      if(results.isNotEmpty){
        throw UserAlreadyExists();
      }

      final userId = await db.insert(userTable, {
        emailColumn: email.toLowerCase(),
      });

      return DatabaseUser(id: userId, email: email);
  }

  //delete the user from database
  Future<void> deleteUser ({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable, 
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      );

      if(deletedCount != 1){//if we try to delete by an non existing user
        throw CouldNotDeleteUser();
      }
  }

  //get the current database
  Database _getDatabaseOrThrow() {
    final db = _db;
    if(db == null){
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  //close database
  Future<void> close() async {
      final db = _db;
      if(db == null){
        throw DatabaseIsNotOpen();
      }else{
        await db.close();
        _db = null;
      }
  }

  Future<void> _ensureDbIsOpen() async {
    try{
      await open();
    } on DatabaseAlreadyOpenException {

    }
  }

  //opening database
  Future<void> open() async {
    if(_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try{
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      //create the user table 
      await db.execute(createUserTable);

      //create note table
      await db.execute(createNoteTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }
}



@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id, 
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;


}


class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id, 
    required this.userId, 
    required this.text, 
    required this.isSyncedWithCloud
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud = 
              (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() => 'Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db'; //files under which our database will be stored
const noteTable = 'note';
const userTable = 'user'; 
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
      "id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      "email"	TEXT NOT NULL UNIQUE
      );''';   

const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "user"("id")
      );''';

      