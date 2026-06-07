import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';

class NotesService {
  final Box box = Hive.box('notesBox');

  List<Note> getNotes() {
    return box.values.cast<Note>().toList();
  }

  void addNote(Note note) {
    box.add(note);
  }

  void editNote(int index, Note note) {
    box.putAt(index, note);
  }

  void deleteNote(int index) {
    box.deleteAt(index);
  }
}
