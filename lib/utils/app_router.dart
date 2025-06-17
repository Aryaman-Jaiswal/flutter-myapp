import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/main_screen_wrapper.dart';
import '../screens/clients/client_list_screen.dart';
import '../screens/clients/client_add_screen.dart';
import '../screens/projects/task_list_screen.dart';
import '../screens/user_management_screen.dart';
import '../screens/users/user_list_screen.dart'; // Import user list screen
import '../screens/users/user_detail_screen.dart'; // Import user detail screen
import '../screens/users/user_edit_screen.dart'; // Import user edit screen
import '../screens/projects/project_list_screen.dart';
// ... (imports)
import '../screens/projects/project_add_screen.dart';

class AppRouter {
  final AuthProvider authProvider;
  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/clients', // A sensible default after login
    refreshListenable: authProvider,
    routes: [
      // --- Routes outside the shell (Login/Signup) ---
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // --- Main application routes wrapped in a ShellRoute ---
      ShellRoute(
        // The builder for the shell itself. This is our main layout.
        // The `child` parameter is the widget for the currently active route.
        builder: (context, state, child) {
          return MainScreenWrapper(
            child: child,
          ); // Pass the active screen as a child
        },
        routes: [
          // The routes that will be displayed within the ShellRoute's `child`
          GoRoute(
            path: '/',
            redirect: (_, __) => '/clients', // Redirect root to /clients
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UserManagementScreen(),
            routes: [
              GoRoute(
                path: 'list', // Matches /users/list
                builder: (context, state) => const UserListScreen(),
              ),
              GoRoute(
                path: 'add', // Matches /users/add
                // We re-use the SignupScreen for adding users
                builder: (context, state) => const SignupScreen(),
              ),
              GoRoute(
                // Dynamic route for user details and editing
                // NOTE: Using user ID is more robust than username
                path: ':userId', // Matches /users/1, /users/2, etc.
                builder: (context, state) {
                  final userId = int.tryParse(
                    state.pathParameters['userId'] ?? '',
                  );
                  if (userId == null) {
                    // Handle error case, e.g., show an error page or redirect
                    return const Scaffold(
                      body: Center(child: Text('Invalid User ID')),
                    );
                  }
                  return UserDetailScreen(userId: userId);
                },
                routes: [
                  GoRoute(
                    path: 'edit', // Matches /users/:userId/edit
                    builder: (context, state) {
                      final userId = int.tryParse(
                        state.pathParameters['userId'] ?? '',
                      );
                      if (userId == null) {
                        return const Scaffold(
                          body: Center(child: Text('Invalid User ID')),
                        );
                      }
                      return UserEditScreen(userId: userId);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectListScreen(),
            routes: [
              GoRoute(
                path: 'add', // Matches /projects/add
                builder: (context, state) => const ProjectAddScreen(),
              ),
              // NEW: Dynamic route for tasks within a project
              GoRoute(
                path: ':projectId', // e.g., /projects/1
                builder: (context, state) {
                  final projectId = int.parse(
                    state.pathParameters['projectId']!,
                  );
                  return TaskListScreen(
                    projectId: projectId,
                  ); // Shows the task list
                },
              ),
            ],
          ),
          GoRoute(
            path: '/clients',
            builder: (context, state) => const ClientListScreen(),
            // Nested route for adding a client
            routes: [
              GoRoute(
                path: 'add', // This will result in the URL: /clients/add
                builder: (context, state) => const ClientAddScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    // Redirect logic to handle authentication
    redirect: (context, state) {
      final loggedIn = authProvider.isAuthenticated;
      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!loggedIn && !loggingIn) {
        return '/login'; // If not logged in and not on auth pages, go to login
      }
      if (loggedIn && loggingIn) {
        return '/clients'; // If logged in and on auth pages, go to a default home page
      }
      return null; // No redirect needed
    },
  );
}
