import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import go_router for navigation
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

import 'users/user_edit_screen.dart';
import 'auth/login_screen.dart';

class MainScreenWrapper extends StatelessWidget {
  // Changed to StatelessWidget
  // NEW: Accept a child widget from ShellRoute
  final Widget child;
  const MainScreenWrapper({super.key, required this.child});

  // Helper to determine selectedIndex from the current URL
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/users')) {
      return 0;
    }
    if (location.startsWith('/clients')) {
      return 1;
    }
    if (location.startsWith('/projects')) {
      return 2;
    }
    return 1; // Default to Clients
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    // --- REMOVED _pages and _selectedIndex state ---

    List<NavigationRailDestination> _railDestinations = [
      NavigationRailDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person),
        label: const Text('User Admin'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.group_outlined),
        selectedIcon: const Icon(Icons.group),
        label: const Text('Clients'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.folder_outlined),
        selectedIcon: const Icon(Icons.folder),
        label: const Text('Projects'),
      ),
    ];

    // Use a fixed width (e.g., 800px) for the main content area on large screens
    bool isExtended = MediaQuery.of(context).size.width > 1000;

    // Optionally, constrain the main content width to 800px and center it
    Widget getConstrainedChild(Widget child) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: child,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        // ... AppBar code remains the same ...
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Image.asset(
                'assets/images/logo.png',
                height: 32,
                width: 32,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.business,
                    color: Colors.grey[700],
                    size: 32,
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          if (currentUser != null)
            GestureDetector(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      child: Text(
                        currentUser.firstName[0],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentUser.firstName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          currentUser.role.toShortString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'logout') {
                          authProvider.logout();
                          context.go('/login'); // Use go_router for navigation
                        } else if (value == 'edit_profile') {
                          if (currentUser != null) {
                            // For nested navigation, using MaterialPageRoute here is fine for now,
                            // or you could define this as a sub-route in go_router too.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserEditScreen(userId: currentUser.id!),
                              ),
                            );
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit_profile',
                              child: Text('Edit My Profile'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'logout',
                              child: Text('Logout'),
                            ),
                          ],
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(height: 1.0, color: Colors.grey[300]),
        ),
      ),
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              selectedIndex: _calculateSelectedIndex(
                context,
              ), // Determine index from URL
              onDestinationSelected: (int index) {
                // Use context.go() to navigate, which updates the URL
                switch (index) {
                  case 0:
                    context.go('/users');
                    break;
                  case 1:
                    context.go('/clients');
                    break;
                  case 2:
                    context.go('/projects');
                    break;
                }
              },
              extended: isExtended,
              labelType: NavigationRailLabelType.none,
              backgroundColor: Colors.white,
              selectedIconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.primary,
              ),
              unselectedIconTheme: IconThemeData(color: Colors.grey[700]),
              selectedLabelTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelTextStyle: TextStyle(color: Colors.grey[700]),
              minExtendedWidth: 200,
              indicatorColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              destinations: _railDestinations,
            ),
          ),
          VerticalDivider(thickness: 1, width: 1, color: Colors.grey[300]),
          Expanded(
            child: child, // Display the active child route here
          ),
        ],
      ),
    );
  }
}
