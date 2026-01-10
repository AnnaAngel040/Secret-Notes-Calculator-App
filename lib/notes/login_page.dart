import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'notes_screen.dart';


// Ensure this imports your main.dart where NotesHomePage is
 
// Re-defining the palette here for easy copy-pasting. 
// Ideally, move this class to a separate file (e.g., theme.dart) and import it.
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
}

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

    // Check if user exists
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

    // Check if user already exists
    if (authBox.get(email) != null) {
      showError("User already exists. Please login.");
      return;
    }

    authBox.put(email, pass);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: RosePine.pine,
        content: Text("Sign up successful! Please login.", style: TextStyle(color: RosePine.base)),
      ),
    );
    toggleMode();
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: RosePine.love,
        content: Text(message, style: const TextStyle(color: RosePine.base)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RosePine.base,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: RosePine.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: RosePine.highlightLow, width: 2),
                ),
                child: Icon(
                  isSignUp ? Icons.person_add_alt_1 : Icons.lock_open_rounded,
                  size: 40,
                  color: RosePine.rose,
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                isSignUp ? "Create Account" : "Welcome Back",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: RosePine.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSignUp ? "Sign up to start taking notes" : "Login to continue",
                style: const TextStyle(color: RosePine.muted),
              ),
              
              const SizedBox(height: 40),

              // EMAIL
              _buildTextField(
                controller: emailCtrl,
                label: "Email",
                icon: Icons.email_outlined,
                obscure: false,
              ),

              const SizedBox(height: 20),

              // PASSWORD
              _buildTextField(
                controller: passCtrl,
                label: "Password",
                icon: Icons.key_outlined,
                obscure: true,
              ),

              const SizedBox(height: 40),

              // ACTION BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RosePine.rose,
                    foregroundColor: RosePine.base,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: isSignUp ? signUp : login,
                  child: Text(
                    isSignUp ? "Sign Up" : "Login",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // TOGGLE BUTTON
              TextButton(
                onPressed: toggleMode,
                style: TextButton.styleFrom(
                  foregroundColor: RosePine.iris,
                ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: RosePine.subtle, fontSize: 15),
                    children: [
                      TextSpan(
                        text: isSignUp
                            ? "Already have an account? "
                            : "Don't have an account? ",
                      ),
                      TextSpan(
                        text: isSignUp ? "Login" : "Sign Up",
                        style: const TextStyle(
                          color: RosePine.iris,
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: RosePine.text),
      cursorColor: RosePine.rose,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: RosePine.muted),
        prefixIcon: Icon(icon, color: RosePine.subtle),
        filled: true,
        fillColor: RosePine.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: RosePine.iris, width: 1.5),
        ),
      ),
    );
  }
}