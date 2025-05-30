import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

import 'user_management_screen.dart';
import 'clients/client_list_screen.dart';
import 'projects/project_list_screen.dart';
import 'users/user_edit_screen.dart';
import 'auth/login_screen.dart';
import '../utils/constants.dart';

class MainScreenWrapper extends StatefulWidget {
  final int initialSelectedIndex;
  const MainScreenWrapper({super.key, this.initialSelectedIndex = 0});

  @override
  State<MainScreenWrapper> createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  late int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    if (!authProvider.isAdmin && _selectedIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedIndex = 1; // Switch to Clients/Groups if not admin
          });
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    final List<Widget> pages = [
      // Index 0: User Administration
      UserManagementScreen(),
      // Index 1: Clients/Groups
      ClientListScreen(),
      // Index 2: Projects
      ProjectListScreen(),
    ];

    List<NavigationRailDestination> railDestinations = [
      NavigationRailDestination(
        icon: Icon(Icons.person),
        label: Text('User Admin'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.group),
        label: Text('Clients'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.folder),
        label: Text('Projects'),
      ),
    ];

    bool isExtended = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1, // Subtle shadow
        title: Row(
          children: [
            // Company Logo Placeholder
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Image.asset(
                // Placeholder if you add logo later
                'lib/assets/images/logo.png', // This path assumes you add an image at assets/images/logo.png
                height: 96, // Adjust size as needed
                width: 144,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.business,
                    color: Colors.grey[700],
                    size: 24,
                  ); // Fallback icon
                },
              ),
            ),
          ],
        ),
        actions: [
          if (currentUser != null)
            GestureDetector(
              onTap: () {
                // Open user profile dropdown or navigate
              },
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
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        } else if (value == 'edit_profile') {
                          if (currentUser != null) {
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
      ),
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                if (index == 0 && !authProvider.isAdmin) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'You do not have permission to access User Administration.',
                      ),
                    ),
                  );
                  return;
                }
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType
                  .none, // Always none for a very compact rail
              extended: false, // Always compact for this design
              // minWidth: 72, // Default, can be smaller if desired
              // minExtendedWidth: 200, // Not applicable if always compact
              destinations: railDestinations,
              backgroundColor: Colors.white,
              selectedIconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.primary,
              ),
              selectedLabelTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
              unselectedIconTheme: IconThemeData(color: Colors.grey[700]),
              unselectedLabelTextStyle: TextStyle(color: Colors.grey[700]),
              indicatorColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: IndexedStack(index: _selectedIndex, children: pages),
            ),
          ),
        ],
      ),
    );
  }
}
