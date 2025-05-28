import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../main_screen_wrapper.dart';

class UserEditScreen extends StatefulWidget {
  final int userId;
  const UserEditScreen({super.key, required this.userId});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _mobileNoController;
  UserRole? _selectedRole;

  User? _user;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _mobileNoController = TextEditingController();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = await userProvider.getUserById(widget.userId);
    if (user != null) {
      setState(() {
        _user = user;
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _emailController.text = user.email;
        _passwordController.text = user.password;
        _mobileNoController.text = user.mobileNo;
        _selectedRole = user.role;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not found.')));
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileNoController.dispose();
    super.dispose();
  }

  void _saveUser() async {
    if (_formKey.currentState!.validate() && _user != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      bool canEditProfile = authProvider.currentUser?.id == _user!.id;
      bool canAssignRoles = authProvider.isAdmin;

      if (!canEditProfile && !canAssignRoles) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You do not have permission to edit this user.'),
          ),
        );
        return;
      }

      final updatedUser = User(
        id: _user!.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        password: _user!.password,
        mobileNo: _mobileNoController.text,
        role: canAssignRoles ? (_selectedRole ?? _user!.role) : _user!.role,
      );

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUser(updatedUser);

      authProvider.updateCurrentUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully!')),
      );
      if (authProvider.currentUser?.id == updatedUser.id &&
          !authProvider.isAdmin) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MainScreenWrapper(initialSelectedIndex: 1),
          ),
          (Route<dynamic> route) => route.isFirst,
        );
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit User')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final authProvider = Provider.of<AuthProvider>(context);
    bool canEditProfile = authProvider.currentUser?.id == _user!.id;
    bool canAssignRoles = authProvider.isAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit User')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
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
                    enabled: canEditProfile || canAssignRoles,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter first name' : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    enabled: canEditProfile || canAssignRoles,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter last name' : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    enabled: canEditProfile || canAssignRoles,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter email';
                      if (!value.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password (Not editable here)',
                    ),
                    obscureText: true,
                    enabled: false,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _mobileNoController,
                    decoration: const InputDecoration(labelText: 'Mobile No'),
                    keyboardType: TextInputType.phone,
                    enabled: canEditProfile || canAssignRoles,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter mobile number' : null,
                  ),
                  const SizedBox(height: 32.0),

                  if (canAssignRoles) ...[
                    DropdownButtonFormField<UserRole>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Assign Role',
                      ),
                      items: UserRole.values.map((UserRole role) {
                        return DropdownMenuItem<UserRole>(
                          value: role,
                          child: Text(role.toShortString()),
                        );
                      }).toList(),
                      onChanged: (UserRole? newValue) {
                        setState(() {
                          _selectedRole = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a role';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32.0),
                  ],
                  ElevatedButton(
                    onPressed: (canEditProfile || canAssignRoles)
                        ? _saveUser
                        : null,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
