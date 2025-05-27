import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../utils/constants.dart'; // For UserRole

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
  final TextEditingController _mobileNoController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileNoController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final newUser = User(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        password: _passwordController.text, 
        mobileNo: _mobileNoController.text,
        role: UserRole.user, // Default role for signup
      );

      await userProvider.addUser(newUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User Registered Successfully!')),
      );

      if (context.canPop()) {
        context.pop(); // Go back to previous screen (e.g., login or user list)
      } else {
        context.go('/login'); // If directly opened, go to login
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Signup')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (value) => value!.isEmpty ? 'Enter first name' : null,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (value) => value!.isEmpty ? 'Enter last name' : null,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter email';
                    if (!value.contains('@')) return 'Enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _mobileNoController,
                  decoration: const InputDecoration(labelText: 'Mobile No'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? 'Enter mobile number' : null,
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: _signup,
                  child: const Text('Sign Up'),
                ),
                TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: const Text('Already have an account? Log In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}