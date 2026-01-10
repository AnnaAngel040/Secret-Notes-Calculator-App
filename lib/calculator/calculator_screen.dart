


import 'package:flutter/material.dart';
import '../notes/login_page.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2A),
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A3D),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _display(),
              const SizedBox(height: 20),
              _buttons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _display() {
    return Container(
      height: 80,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161623),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        display,
        style: const TextStyle(fontSize: 32, color: Colors.white),
      ),
    );
  }

  Widget _buttons() {
    final keys = [
      "7", "8", "9", "/",
      "4", "5", "6", "*",
      "1", "2", "3", "-",
      "0", "C", "=", "+",
    ];

    return GridView.builder(
      shrinkWrap: true,
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, index) {
        final key = keys[index];
        return ElevatedButton(
          onPressed: () => _onButtonPress(key),
          style: ElevatedButton.styleFrom(
            backgroundColor: _buttonColor(key),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(key, style: const TextStyle(fontSize: 20)),
        );
      },
    );
  }

  Color _buttonColor(String key) {
    if (key == "=") return Colors.pinkAccent;
    if ("+-*/".contains(key)) return Colors.indigoAccent;
    if (key == "C") return Colors.orangeAccent;
    return Colors.blueGrey;
  }

  void _onButtonPress(String key) {
    setState(() {
      if (key == "C") {
        display = "";
      } else if (key == "=") {
        _handleEquals();
      } else {
        display += key;
      }
    });
  }

  void _handleEquals() {
    if (display == "69/67") {
      display = "";
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
      return;
    }

    try {
      display = _evaluate(display).toString();
    } catch (_) {
      display = "Error";
    }
  }

  double _evaluate(String expression) {
    final match = RegExp(r'(\d+)([+\-*/])(\d+)').firstMatch(expression);
    if (match == null) throw Exception();

    final a = double.parse(match.group(1)!);
    final b = double.parse(match.group(3)!);

    switch (match.group(2)) {
      case '+': return a + b;
      case '-': return a - b;
      case '*': return a * b;
      case '/': return a / b;
      default: throw Exception();
    }
  }
}





