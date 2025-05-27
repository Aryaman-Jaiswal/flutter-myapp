import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/users/user_list_screen.dart';
import '../screens/users/user_detail_screen.dart';
import '../screens/clients/client_add_screen.dart';
import '../screens/clients/client_list_screen.dart';
import '../screens/users/user_edit_screen.dart';

class AppRouter {
  final AuthProvider authProvider; // Get instance from main.dart

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: authProvider,
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // User Management Routes
          GoRoute(
            path: 'users',
            builder: (context, state) => const UserListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const SignupScreen(),
              ),
              GoRoute(
                path: ':id', // Parameterized route for user ID
                builder: (context, state) {
                  final userId = int.tryParse(state.pathParameters['id']!);
                  if (userId == null) {
                    return const Text('Invalid User ID');
                  }
                  return UserDetailScreen(userId: userId);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'users/:id/edit',
            builder: (context, state) {
              final userId = int.tryParse(state.pathParameters['id']!);
              if (userId == null) {
                return const Text('Invalid User ID');
              }
              return UserEditScreen(userId: userId);
            },
          ),
          // Client Management Routes
          GoRoute(
            path: 'clients/add',
            builder: (context, state) => const ClientAddScreen(),
          ),
          GoRoute(
            path: 'clients',
            builder: (context, state) => const ClientListScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      // Logic to redirect based on authentication status
      final loggedIn = authProvider.isAuthenticated;
      final loggingIn =
          state.fullPath == '/login' || state.fullPath == '/signup';

      if (!loggedIn && !loggingIn) {
        return '/login';
      }
      if (loggedIn && loggingIn) {
        return '/'; // Logged in, but trying to access auth pages, redirect to home
      }
      return null;
    },
    errorBuilder: (context, state) => Text('Error: ${state.error}'),
  );
}
