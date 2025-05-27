import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              context.go('/login'); 
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentUser != null
                  ? 'Welcome, ${currentUser.firstName} ${currentUser.lastName}!'
                  : 'Welcome, Guest!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 40),

          
            ElevatedButton(
              onPressed: () {
                if (currentUser != null) {
                  context.go('/users/${currentUser.id}/edit');
                }
              },
              child: const Text('Edit My Profile'),
            ),
            const SizedBox(height: 20),

            // Admin/Super Admin actions
            if (authProvider.isAdmin) ...[
              ElevatedButton(
                onPressed: () {
                  context.go('/users');
                },
                child: const Text('View All Users'),
              ),
              const SizedBox(height: 20),
            ],

            ElevatedButton(
              onPressed: () {
                context.go('/clients/add');
              },
              child: const Text('Add New Client'),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                context.go('/clients');
              },
              child: const Text('View Clients'),
            ),
          ],
        ),
      ),
    );
  }
}
