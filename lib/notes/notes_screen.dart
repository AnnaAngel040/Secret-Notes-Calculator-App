import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login_page.dart'; 
import '../services/notes_service.dart';

// ----------------------------------------------------------
// ROSÉ PINE COLOR PALETTEno
// ----------------------------------------------------------
class RosePine {
  static const Color base = Color(0xFF191724);
  static const Color surface = Color(0xFF1f1d2e);
  static const Color overlay = Color(0xFF26233a);
  static const Color muted = Color(0xFF6e6a86);
  static const Color subtle = Color(0xFF908caa);
  static const Color text = Color(0xFFe0def4);
  static const Color love = Color(0xFFeb6f92);
  static const Color gold = Color(0xFFf6c177);
  static const Color rose = Color(0xFFebbcba);
  static const Color pine = Color(0xFF31748f);
  static const Color foam = Color(0xFF9ccfd8);
  static const Color iris = Color(0xFFc4a7e7);
  static const Color highlightLow = Color(0xFF21202e);
  static const Color highlightMed = Color(0xFF403d52);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('notesBox');
  await Hive.openBox('authBox');

  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes',
      theme: ThemeData(
        fontFamily: 'Roboto', // Or your preferred font
        scaffoldBackgroundColor: RosePine.base,
        brightness: Brightness.dark,
        primaryColor: RosePine.iris,
        colorScheme: const ColorScheme.dark(
          primary: RosePine.iris,
          secondary: RosePine.rose,
          surface: RosePine.surface,
          error: RosePine.love,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: RosePine.base,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: RosePine.text,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: RosePine.subtle),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 212, 131, 128),
          foregroundColor: RosePine.base,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: RosePine.rose,
          selectionColor: RosePine.highlightMed,
          selectionHandleColor: RosePine.rose,
        ),
      ),
      home: AuthGate(),
    );
  }
}

// ----------------------------------------------------------
// AUTH GATE
// ----------------------------------------------------------
class AuthGate extends StatelessWidget {
  AuthGate({super.key});
  final authBox = Hive.box('authBox');

  @override
  Widget build(BuildContext context) {
    final currentUser = authBox.get('currentUser');
    return currentUser != null ? const NotesHomePage() : const LoginPage();
  }
}

// ----------------------------------------------------------
// ----------------------------------------------------------
// NOTES PAGE
// ----------------------------------------------------------
class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  final NotesService notesService = NotesService();

  List<String> notes = [];
  List<String> filteredNotes = [];

  final TextEditingController noteController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
    searchController.addListener(filterNotes);
  }

  @override
  void dispose() {
    noteController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _loadNotes() {
    notes = notesService.getNotes();
    filteredNotes = List.from(notes);
  }

  void filterNotes() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredNotes =
          notes.where((n) => n.toLowerCase().contains(query)).toList();
    });
  }


  void addNote() {
    if (noteController.text.trim().isNotEmpty) {
      setState(() {
        notesService.addNote(noteController.text.trim());
        _loadNotes();
        filterNotes();
      });
      noteController.clear();
      Navigator.pop(context);
    }
  }

  void openAddNoteDialog() {
    noteController.clear();
    showDialog(
      context: context,
      builder: (_) => _buildNoteDialog(
        title: "New Note",
        onSave: addNote,
        btnText: "Create",
      ),
    );
  }

  void openEditNoteDialog(int filteredIndex) {
    final realIndex = notes.indexOf(filteredNotes[filteredIndex]);
    noteController.text = notes[realIndex];

    showDialog(
      context: context,
      builder: (_) => _buildNoteDialog(
        title: "Edit Note",
        onSave: () {
          setState(() {
            notesService.editNote(realIndex, noteController.text.trim());
            _loadNotes();
            filterNotes();
          });
          noteController.clear();
          Navigator.pop(context);
        },
        btnText: "Save Changes",
      ),
    );
  }
  
  void deleteNote(int filteredIndex) {
    final realIndex = notes.indexOf(filteredNotes[filteredIndex]);
    setState(() {
      notesService.deleteNote(realIndex);
      _loadNotes();
      filterNotes();
    });
  }

  Widget _buildNoteDialog({
    required String title,
    required VoidCallback onSave,
    required String btnText,
  }) {
    return AlertDialog(
      backgroundColor: RosePine.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: const TextStyle(color: RosePine.rose, fontWeight: FontWeight.bold)),
      content: TextField(
        controller: noteController,
        style: const TextStyle(color: RosePine.text, fontSize: 16),
        maxLines: null,
        minLines: 5,
        keyboardType: TextInputType.multiline,
        cursorColor: RosePine.rose,
        decoration: InputDecoration(
          hintText: "What's on your mind?",
          hintStyle: const TextStyle(color: RosePine.muted),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: RosePine.overlay,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text("Cancel", style: TextStyle(color: RosePine.subtle))
        ),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(backgroundColor: RosePine.pine, foregroundColor: RosePine.base),
          child: Text(btnText),
        ),
      ],
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: RosePine.base,
      appBar: AppBar(
        
        title: const Text("My Notes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Hive.box('authBox').delete('currentUser');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: RosePine.text),
              cursorColor: RosePine.iris,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: RosePine.muted),
                hintText: "Search...",
                hintStyle: const TextStyle(color: RosePine.muted),
                filled: true,
                fillColor: RosePine.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),

          // WRAP LAYOUT - This replaces the Grid/Row logic
          Expanded(
            child: filteredNotes.isEmpty
                ? const Center(
                    child: Text("No notes yet", style: TextStyle(color: RosePine.muted)),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    // Wrap allows items to flow like text. 
                    // Width is determined by content, Height by content.
                    child: SizedBox(
                      width: double.infinity, // Ensure the wrap container fills width
                      child: Wrap(
                        spacing: 12, // Gap between items horizontally
                        runSpacing: 12, // Gap between lines vertically
                        crossAxisAlignment: WrapCrossAlignment.start,
                        alignment: WrapAlignment.start, // Align to left
                        children: List.generate(filteredNotes.length, (index) {
                          return _buildNoteCard(index);
                        }),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddNoteDialog,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }

  Widget _buildNoteCard(int index) {
    final content = filteredNotes[index];

    return IntrinsicWidth(
      child: Container(
        // Set a max width so huge text doesn't break the layout, 
        
        constraints: const BoxConstraints(
          minWidth: 50, // Minimum size for very short notes
          maxWidth: 360, // Prevents note from being wider than screen
        ),
        decoration: BoxDecoration(
          color: RosePine.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RosePine.highlightLow),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => openEditNoteDialog(index),
            splashColor: RosePine.overlay,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Shrink height to fit
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: const TextStyle(
                      color: RosePine.text,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: () => deleteNote(index),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: RosePine.love,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
