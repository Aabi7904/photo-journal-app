import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:photo_journal_app/services/auth_service.dart';

// We will create this screen next
import 'package:photo_journal_app/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AUthService _authService = AUthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obsecure = true;

  void _login() async {
    // First, check if the form is valid (e.g., fields are not empty)
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Call the signInWithEmail method from our AuthService
      await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // If the login fails, the screen will still be visible, so we stop the loader.
      // If it succeeds, the AuthGate will switch to the HomeScreen automatically.
      //mounted will say whether the screen is still alive or not
      //coz when the user taps back or taps to another screen
      //we say the loading to false which the screen is not there it will crash the app
      //so mounted will help in that
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _googleSignIn() async {
    setState(() {
      _isLoading = true;
    });
    _authService.signInWithGoogle();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void passvisiblity() {
    setState(() {
      _obsecure = !_obsecure;
    });
  }

  //dispose is a stfull class method
  //we are customizing it so we use @override
  @override
  //dispose clears the controllers coz it buses memory
  //after we change screens it clears the memory
  //so app wont get slow,not uses more memory, no crash
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    //this is a default state class (parent) dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // New: Added a subtle gradient background
      backgroundColor: Colors.blueGrey[50],
      //safe area will help to adjuse according to notches both above and below
      body: SafeArea(
        child: Center(
          //singlechildview makes the screen scrollable when content is not fit
          //mainly for small screens
          //it will work only in single schild
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Section
                Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: Colors.blueGrey.shade300,
                ),
                const SizedBox(height: 24),
                Text(
                  "Welcome Back",
                  //we are using app theme here
                  //.copywith says we are just customizing it
                  //not creating any new style
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign in to access your journal",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.blueGrey.shade400,
                  ),
                ),
                const SizedBox(height: 48),

                // Form Section
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "Email Address",
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value!.isEmpty ? "Please enter an email" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          suffixIcon: IconButton(
                            onPressed: passvisiblity,
                            icon: Icon(
                              _obsecure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                          prefixIcon: Icon(Icons.lock_outline_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        obscureText: _obsecure,
                        validator: (value) => value!.length < 6
                            ? "Password must be at least 6 characters"
                            : null,
                      ),
                      const SizedBox(height: 32),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: Colors.blueGrey.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("LOGIN"),
                            ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          _googleSignIn();
                        },
                        icon: Image.asset('assets/google_logo.png', height: 22),
                        label: Text("Sign in with Google"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text("Don't have an account? Sign Up"),
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms), // Animate all children
          ),
        ),
      ),
    );
  }
}
