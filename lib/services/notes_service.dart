import 'package:hive_flutter/hive_flutter.dart';

class NotesService {
  final Box box = Hive.box('notesBox');

  List<String> getNotes() {
    return box.values.map((e) => e.toString()).toList();
  }

  void addNote(String note) {
    box.add(note);
  }

  void editNote(int index, String note) {
    box.putAt(index, note);
  }

  void deleteNote(int index) {
    box.deleteAt(index);
  }
}
