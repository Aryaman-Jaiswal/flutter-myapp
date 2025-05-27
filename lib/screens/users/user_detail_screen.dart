import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart'; 
import '../../utils/constants.dart';

class UserDetailScreen extends StatelessWidget {
  final int userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        actions: [
          if (authProvider.isAdmin || authProvider.currentUser?.id == userId)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.go('/users/$userId/edit');
              },
            ),
        ],
      ),
      body: FutureBuilder<User?>(
        future: userProvider.getUserById(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User not found.'));
          } else {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('First Name:', user.firstName),
                  _buildDetailRow('Last Name:', user.lastName),
                  _buildDetailRow('Email:', user.email),
                  _buildDetailRow('Mobile No:', user.mobileNo),
                  _buildDetailRow('Role:', user.role.toShortString()),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}