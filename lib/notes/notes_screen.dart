import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login_page.dart'; 
import '../services/notes_service.dart';
import '../models/note.dart';
import '../theme/neon_theme.dart';
import 'dart:ui';

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neon Notes',
      theme: NeonTheme.theme,
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  AuthGate({super.key});
  final authBox = Hive.box('authBox');

  @override
  Widget build(BuildContext context) {
    final currentUser = authBox.get('currentUser');
    return currentUser != null ? const NotesHomePage() : const LoginPage();
  }
}

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  final NotesService notesService = NotesService();

  List<Note> notes = [];
  List<Note> filteredNotes = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final List<String> categories = ['Personal', 'Work', 'Ideas'];
  String selectedCategory = 'Personal';
  String filterCategory = 'Personal';

  @override
  void initState() {
    super.initState();
    _loadNotes();
    searchController.addListener(filterNotes);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _loadNotes() {
    notes = notesService.getNotes();
    filterNotes();
  }

  void filterNotes() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredNotes = notes.where((n) {
        final matchesQuery = n.title.toLowerCase().contains(query) || n.content.toLowerCase().contains(query);
        final matchesCategory = n.category == filterCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void addNote() {
    if (titleController.text.trim().isNotEmpty || contentController.text.trim().isNotEmpty) {
      setState(() {
        notesService.addNote(Note(
          title: titleController.text.trim().isEmpty ? 'Untitled' : titleController.text.trim(),
          content: contentController.text.trim(),
          category: selectedCategory,
        ));
        _loadNotes();
      });
      titleController.clear();
      contentController.clear();
      Navigator.pop(context);
    }
  }

  void openAddNoteDialog() {
    titleController.clear();
    contentController.clear();
    selectedCategory = filterCategory; // Default to current view

    showDialog(
      context: context,
      builder: (_) => _buildNoteDialog(
        dialogTitle: "New Note",
        onSave: addNote,
        btnText: "Create",
      ),
    );
  }

  void openEditNoteDialog(int filteredIndex) {
    final realIndex = notes.indexOf(filteredNotes[filteredIndex]);
    final note = notes[realIndex];
    titleController.text = note.title;
    contentController.text = note.content;
    selectedCategory = note.category;

    showDialog(
      context: context,
      builder: (_) => _buildNoteDialog(
        dialogTitle: "Edit Note",
        onSave: () {
          setState(() {
            notesService.editNote(realIndex, Note(
              title: titleController.text.trim().isEmpty ? 'Untitled' : titleController.text.trim(),
              content: contentController.text.trim(),
              category: selectedCategory,
            ));
            _loadNotes();
          });
          titleController.clear();
          contentController.clear();
          Navigator.pop(context);
        },
        btnText: "Save",
      ),
    );
  }
  
  void deleteNote(int filteredIndex) {
    final realIndex = notes.indexOf(filteredNotes[filteredIndex]);
    setState(() {
      notesService.deleteNote(realIndex);
      _loadNotes();
    });
  }

  Widget _buildNoteDialog({
    required String dialogTitle,
    required VoidCallback onSave,
    required String btnText,
  }) {
    return StatefulBuilder(
      builder: (context, setStateDialog) {
        return AlertDialog(
          backgroundColor: NeonColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: NeonColors.cyan.withValues(alpha: 0.5)),
          ),
          title: Text(dialogTitle, style: const TextStyle(color: NeonColors.cyan, fontWeight: FontWeight.bold, shadows: [Shadow(color: NeonColors.cyan, blurRadius: 10)])),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  dropdownColor: NeonColors.surface,
                  style: const TextStyle(color: NeonColors.textLight),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: const TextStyle(color: NeonColors.textMuted),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: NeonColors.cyan.withValues(alpha: 0.3))),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: NeonColors.cyan)),
                  ),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => selectedCategory = val);
                  },
                ),
                const SizedBox(height: 16),
                
                // Title
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: NeonColors.textLight, fontWeight: FontWeight.bold),
                  cursorColor: NeonColors.cyan,
                  decoration: InputDecoration(
                    hintText: "Title",
                    hintStyle: const TextStyle(color: NeonColors.textMuted),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: NeonColors.cyan.withValues(alpha: 0.3))),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: NeonColors.cyan)),
                  ),
                ),
                const SizedBox(height: 16),

                // Content
                TextField(
                  controller: contentController,
                  style: const TextStyle(color: NeonColors.textLight, fontSize: 16),
                  maxLines: null,
                  minLines: 5,
                  keyboardType: TextInputType.multiline,
                  cursorColor: NeonColors.cyan,
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                    hintStyle: const TextStyle(color: NeonColors.textMuted),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cancel", style: TextStyle(color: NeonColors.textMuted))
            ),
            ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(backgroundColor: NeonColors.cyan, foregroundColor: NeonColors.background),
              child: Text(btnText),
            ),
          ],
        );
      }
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonColors.background,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT SIDEBAR
            _buildSidebar(),
            
            // MAIN CONTENT
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildSearchBar(),
                  Expanded(
                    child: _buildNotesGrid(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: NeonColors.cyan.withValues(alpha: 0.6),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: FloatingActionButton(
          onPressed: openAddNoteDialog,
          backgroundColor: NeonColors.cyan,
          child: const Icon(Icons.add_rounded, size: 32, color: NeonColors.background),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: NeonColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: NeonColors.cyan.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: NeonColors.cyan.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 32),
            child: Text(
              "Categories",
              style: TextStyle(
                color: NeonColors.cyan,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: NeonColors.cyan, blurRadius: 10)],
              ),
            ),
          ),
          ...categories.map((cat) {
            bool isSelected = filterCategory == cat;
            return InkWell(
              onTap: () {
                setState(() {
                  filterCategory = cat;
                  _loadNotes(); // Re-filter
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? NeonColors.cyan.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(color: NeonColors.cyan.withValues(alpha: 0.5)) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconForCategory(cat),
                      color: isSelected ? NeonColors.cyan : NeonColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? NeonColors.cyan : NeonColors.textMuted,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String cat) {
    switch (cat) {
      case 'Work': return Icons.work_outline;
      case 'Ideas': return Icons.lightbulb_outline;
      default: return Icons.person_outline;
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Neon Notes",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: NeonColors.textLight,
            ),
          ),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: NeonColors.surface,
                child: Icon(Icons.person, color: NeonColors.cyan),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Hive.box('authBox').delete('currentUser');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: NeonColors.surface,
                  foregroundColor: NeonColors.textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: NeonColors.textMuted.withValues(alpha: 0.2)),
                  ),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text("Logout"),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: NeonColors.cyan.withValues(alpha: 0.1),
              blurRadius: 10,
            )
          ]
        ),
        child: TextField(
          controller: searchController,
          style: const TextStyle(color: NeonColors.textLight),
          cursorColor: NeonColors.cyan,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: NeonColors.cyan),
            hintText: "Search notes...",
            hintStyle: const TextStyle(color: NeonColors.textMuted),
            filled: true,
            fillColor: NeonColors.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: NeonColors.cyan.withValues(alpha: 0.5), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: NeonColors.cyan, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesGrid() {
    if (filteredNotes.isEmpty) {
      return const Center(
        child: Text("No notes in this category yet", style: TextStyle(color: NeonColors.textMuted)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.start,
          alignment: WrapAlignment.start,
          children: List.generate(filteredNotes.length, (index) {
            return _buildNoteCard(index);
          }),
        ),
      ),
    );
  }

  Widget _buildNoteCard(int index) {
    final note = filteredNotes[index];

    return IntrinsicWidth(
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 250,
          maxWidth: 300,
        ),
        decoration: BoxDecoration(
          color: NeonColors.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NeonColors.cyan.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: NeonColors.cyan.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => openEditNoteDialog(index),
                splashColor: NeonColors.cyan.withValues(alpha: 0.2),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              note.title,
                              style: const TextStyle(
                                color: NeonColors.textLight,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => deleteNote(index),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: NeonColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        note.content,
                        style: const TextStyle(
                          color: NeonColors.textMuted,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
