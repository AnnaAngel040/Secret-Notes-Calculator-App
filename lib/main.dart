import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'calculator/calculator_screen.dart';


import 'models/note.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(NoteAdapter());

  await Hive.openBox('authBox');
  await Hive.openBox('notesBox'); // ✅ FIXED
  
  runApp(const CalculatorVaultApp());
}


class CalculatorVaultApp extends StatelessWidget {
  const CalculatorVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    );
  }
}
