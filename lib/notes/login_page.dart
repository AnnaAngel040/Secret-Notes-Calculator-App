import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'notes_screen.dart';
import '../theme/neon_theme.dart';
import 'dart:math' as math;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authBox = Hive.box('authBox');
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  bool isSignUp = false;

  void toggleMode() {
    setState(() {
      isSignUp = !isSignUp;
      emailCtrl.clear();
      passCtrl.clear();
    });
  }

  void login() {
    String email = emailCtrl.text.trim();
    String pass = passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      showError("Enter email & password");
      return;
    }

    String? storedPass = authBox.get(email);
    if (storedPass == null) {
      showError("User not found. Please sign up.");
      return;
    }

    if (storedPass != pass) {
      showError("Incorrect password");
      return;
    }

    authBox.put('loggedIn', true);
    authBox.put('currentUser', email);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NotesHomePage()),
    );
  }

  void signUp() {
    String email = emailCtrl.text.trim();
    String pass = passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      showError("Enter email & password");
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      showError("Enter a valid email");
      return;
    }

    if (pass.length < 6) {
      showError("Password must be at least 6 characters");
      return;
    }

    if (authBox.get(email) != null) {
      showError("User already exists. Please login.");
      return;
    }

    authBox.put(email, pass);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: NeonColors.cyan,
        content: Text("Sign up successful! Please login.", style: TextStyle(color: NeonColors.background, fontWeight: FontWeight.bold)),
      ),
    );
    toggleMode();
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: NeonColors.danger,
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonColors.background,
      body: Stack(
        children: [
          // Background Neon Shapes
          Positioned.fill(
            child: CustomPaint(
              painter: NeonBackgroundPainter(),
            ),
          ),
          
          // Glassmorphism Login Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: NeonColors.cyan.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: NeonColors.cyan.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Glowing Lock Icon
                        Icon(
                          isSignUp ? Icons.person_add_outlined : Icons.lock_outline,
                          size: 60,
                          color: NeonColors.cyan,
                          shadows: [
                            Shadow(
                              color: NeonColors.cyan,
                              blurRadius: 15,
                            )
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        Text(
                          isSignUp ? "Create Account" : "Welcome Back",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: NeonColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isSignUp ? "Sign up to start taking notes" : "Login to continue",
                          style: const TextStyle(color: NeonColors.textMuted),
                        ),
                        
                        const SizedBox(height: 32),

                        // EMAIL
                        _buildTextField(
                          controller: emailCtrl,
                          label: "Email",
                          obscure: false,
                        ),

                        const SizedBox(height: 16),

                        // PASSWORD
                        _buildTextField(
                          controller: passCtrl,
                          label: "Password",
                          obscure: true,
                        ),

                        const SizedBox(height: 32),

                        // ACTION BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: NeonColors.cyan.withValues(alpha: 0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: NeonColors.cyan,
                                foregroundColor: NeonColors.background,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isSignUp ? signUp : login,
                              child: Text(
                                isSignUp ? "Sign Up" : "Login",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // TOGGLE BUTTON
                        TextButton(
                          onPressed: toggleMode,
                          style: TextButton.styleFrom(
                            foregroundColor: NeonColors.cyan,
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: NeonColors.textMuted, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: isSignUp
                                      ? "Already have an account? "
                                      : "Don't have an account? ",
                                ),
                                TextSpan(
                                  text: isSignUp ? "Login" : "Sign Up",
                                  style: const TextStyle(
                                    color: NeonColors.cyan,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: NeonColors.textLight),
      cursorColor: NeonColors.cyan,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: NeonColors.textMuted),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: NeonColors.cyan.withValues(alpha: 0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NeonColors.cyan, width: 2),
        ),
      ),
    );
  }
}

class NeonBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NeonColors.cyan.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Add glowing effect to the strokes
    paint.imageFilter = ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0);

    // Draw some random abstract shapes similar to the reference image
    // Triangle top right
    final path1 = Path();
    path1.moveTo(size.width * 0.8, size.height * 0.1);
    path1.lineTo(size.width * 0.9, size.height * 0.2);
    path1.lineTo(size.width * 0.7, size.height * 0.2);
    path1.close();
    canvas.drawPath(path1, paint);

    // Line top left
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.3),
      Offset(size.width * 0.3, size.height * 0.1),
      paint,
    );

    // Triangle bottom left
    final path2 = Path();
    path2.moveTo(size.width * 0.1, size.height * 0.8);
    path2.lineTo(size.width * 0.2, size.height * 0.9);
    path2.lineTo(size.width * 0.05, size.height * 0.9);
    path2.close();
    canvas.drawPath(path2, paint);

    // Line bottom right
    final purplePaint = Paint()
      ..color = const Color(0xFF6B4EE6).withValues(alpha: 0.6) // Neon purple/blue accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..imageFilter = ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0);

    canvas.drawLine(
      Offset(size.width * 0.7, size.height * 0.8),
      Offset(size.width * 0.9, size.height * 0.6),
      purplePaint,
    );

    // Curve or extra shape in center background
    final path3 = Path();
    path3.moveTo(size.width * 0.4, size.height * 0.4);
    path3.quadraticBezierTo(size.width * 0.5, size.height * 0.2, size.width * 0.6, size.height * 0.4);
    path3.quadraticBezierTo(size.width * 0.7, size.height * 0.6, size.width * 0.4, size.height * 0.6);
    path3.close();
    
    final dimPaint = Paint()
      ..color = NeonColors.cyan.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..imageFilter = ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0);
    
    canvas.drawPath(path3, dimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}