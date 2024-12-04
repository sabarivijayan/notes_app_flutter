import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:notes_app/models/note.dart';
import 'package:path_provider/path_provider.dart';

class NoteDatabase extends ChangeNotifier{
  static late Isar isar;
  //Initialize
  static Future<void> init() async {
    final dir = await getApplicationCacheDirectory();
    isar = await Isar.open([NoteSchema], directory: dir.path);
  }

  //list of notes
  final List<Note> currentNotes = [];

  //create
  Future<void> addNotes(String textFromUser) async {
    final newNote = Note()..text = textFromUser;

    await isar.writeTxn(() async {
      await isar.notes.put(newNote);
    });
    await fetchNotes();
  }

  //read
  Future<void> fetchNotes() async {
    List<Note> fetchedNotes = await isar.notes.where().findAll();
    currentNotes.clear();
    currentNotes.addAll(fetchedNotes);
    notifyListeners();
  }

  //update
  Future<void> updateNote(int id, String newText) async {
    final existingNote = await isar.notes.get(id);
    if (existingNote != null) {
      existingNote.text = newText;
      await isar.writeTxn(() async {
        await isar.notes.put(existingNote);
        await fetchNotes();
      });
    }
  }
  //delete
  Future<void> deleteNote(int id) async {
    await isar.writeTxn(()=> isar.notes.delete(id));
    await fetchNotes();
  }
}
