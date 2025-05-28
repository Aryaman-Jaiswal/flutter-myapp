import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../main_screen_wrapper.dart';
import 'signup_screen.dart';
import '../../utils/login_clipper.dart';
import 'package:animate_do/animate_do.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const Color _primaryPurple = Color.fromRGBO(143, 148, 251, 1);
  static const Color _lightPurple = Color.fromRGBO(143, 148, 251, .6);
  static const Color _darkGrey = Colors.grey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        final int initialTab = auth.isAdmin ? 0 : 1;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                MainScreenWrapper(initialSelectedIndex: initialTab),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      bool success = await auth.login(
        _emailController.text,
        _passwordController.text,
      );

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login Successful!')));
        final int initialTab = auth.isAdmin ? 0 : 1;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                MainScreenWrapper(initialSelectedIndex: initialTab),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Email or Password')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // --- Top Section with Wave and "Login" Text ---
            ClipPath(
              clipper: LoginClipper(),
              child: Container(
                height: screenHeight * 0.45,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryPurple, _lightPurple],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  // Still using Stack as 'Login' text is Positioned
                  children: <Widget>[
                    // --- REMOVED THESE POSITIONED WIDGETS ---
                    // Positioned(
                    //   left: 30,
                    //   width: 80,
                    //   height: screenHeight * 0.2,
                    //   child: FadeInUp(duration: Duration(seconds: 1), child: Container(
                    //      color: Colors.white.withOpacity(0.2),
                    //      alignment: Alignment.center,
                    //      child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 40),
                    //   )),
                    // ),
                    // Positioned(
                    //   left: 140,
                    //   width: 80,
                    //   height: screenHeight * 0.15,
                    //   child: FadeInUp(duration: Duration(milliseconds: 1200), child: Container(
                    //      color: Colors.white.withOpacity(0.15),
                    //      alignment: Alignment.center,
                    //      child: const Icon(Icons.lightbulb_outline, color: Colors.white70, size: 30),
                    //   )),
                    // ),
                    // Positioned(
                    //   right: 40,
                    //   top: 40,
                    //   width: 80,
                    //   height: screenHeight * 0.15,
                    //   child: FadeInUp(duration: Duration(milliseconds: 1300), child: Container(
                    //      color: Colors.white.withOpacity(0.1),
                    //      alignment: Alignment.center,
                    //      child: const Icon(Icons.access_time, color: Colors.white54, size: 40),
                    //   )),
                    // ),
                    // --- END REMOVED POSITIONED WIDGETS ---
                    Positioned(
                      child: FadeInUp(
                        duration: Duration(milliseconds: 1600),
                        child: Container(
                          margin: EdgeInsets.only(top: screenHeight * 0.05),
                          child: const Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // --- End Top Section ---

            // --- Form Section ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 15.0,
              ),
              child: Column(
                children: <Widget>[
                  FadeInUp(
                    duration: Duration(milliseconds: 1800),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _primaryPurple),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(143, 148, 251, .2),
                            blurRadius: 20.0,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            // Email/Phone Number Field
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: _primaryPurple),
                                ),
                              ),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Email or Phone number",
                                  hintStyle: TextStyle(color: _darkGrey),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email or phone number';
                                  }
                                  if (!value.contains('@') &&
                                      !RegExp(r'^\d+$').hasMatch(value)) {
                                    return 'Enter a valid email or phone number';
                                  }
                                  return null;
                                },
                                style: TextStyle(color: _darkGrey),
                              ),
                            ),
                            // Password Field
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Password",
                                  hintStyle: TextStyle(color: _darkGrey),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                                style: TextStyle(color: _darkGrey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  FadeInUp(
                    duration: Duration(milliseconds: 1900),
                    child: GestureDetector(
                      onTap: _login,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [_primaryPurple, _lightPurple],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Forgot Password? Text Button
                  FadeInUp(
                    duration: Duration(milliseconds: 2000),
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Forgot Password? Not implemented yet.',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: _primaryPurple),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sign Up button
                  FadeInUp(
                    duration: Duration(milliseconds: 2100),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignupScreen(),
                          ),
                        );
                      },
                      child: const Text('Don\'t have an account? Sign Up'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
