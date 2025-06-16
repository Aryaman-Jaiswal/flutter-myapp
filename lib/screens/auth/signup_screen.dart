import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../utils/constants.dart';
import 'package:animate_do/animate_do.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();

  static const Color _primaryBlue = Color(0xFF007BFF);
  static const Color _lightBlue = Color(0xFF6CACEA);
  static const Color _greyHintText = Colors.grey;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _mobileNoController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match!')),
        );
        return;
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchUsers(); // Make sure the user list is up-to-date
      final bool isFirstUser = userProvider.users.isEmpty;
      final newUser = User(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        mobileNo: _mobileNoController.text,
        role: isFirstUser ? UserRole.superAdmin : UserRole.user,
      );

      await userProvider.addUser(newUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User Registered Successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // Center the content horizontally
        child: ConstrainedBox(
          // Apply a maximum width
          constraints: const BoxConstraints(
            maxWidth:
                600, // Max width for the form (adjust as needed, 600px is a good standard for forms)
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // --- Top Section: Title and Subtitle ---
                FadeInUp(
                  duration: const Duration(milliseconds: 300),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInUp(
                  duration: const Duration(milliseconds: 350),
                  child: Text(
                    'Create an account, It\'s free',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 40),

                // --- Form Fields ---
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: _inputDecoration(
                            hintText: 'First Name',
                            labelText: 'First Name',
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter first name' : null,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      FadeInUp(
                        duration: const Duration(milliseconds: 450),
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: _inputDecoration(
                            hintText: 'Last Name',
                            labelText: 'Last Name',
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter last name' : null,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            hintText: 'Email',
                            labelText: 'Email',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Enter email';
                            if (!value.contains('@'))
                              return 'Enter valid email';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      FadeInUp(
                        duration: const Duration(milliseconds: 550),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: _inputDecoration(
                            hintText: 'Password',
                            labelText: 'Password',
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter password' : null,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: _inputDecoration(
                            hintText: 'Confirm Password',
                            labelText: 'Confirm Password',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Confirm your password';
                            if (value != _passwordController.text)
                              return 'Passwords do not match';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      FadeInUp(
                        duration: const Duration(milliseconds: 650),
                        child: TextFormField(
                          controller: _mobileNoController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration(
                            hintText: 'Mobile Number',
                            labelText: 'Mobile Number',
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter mobile number' : null,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- Sign Up Button ---
                      FadeInUp(
                        duration: const Duration(milliseconds: 700),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _signup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- Already have an account? Login button ---
                      FadeInUp(
                        duration: const Duration(milliseconds: 750),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              children: <TextSpan>[
                                const TextSpan(
                                  text: 'Already have an account? ',
                                ),
                                TextSpan(
                                  text: 'Login',
                                  style: TextStyle(
                                    color: _primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, String? labelText}) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: TextStyle(color: _greyHintText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _primaryBlue, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 16.0,
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
