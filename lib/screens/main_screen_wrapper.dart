import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'user_management_screen.dart';

import 'clients/client_tab_navigator.dart';
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
            _selectedIndex = 1;
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
      UserManagementScreen(),
      const ClientTabNavigator(),
      ProjectListScreen(),
    ];

    List<NavigationRailDestination> railDestinations = [
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

    bool isExtended = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Image.asset(
                'lib/assets/images/logo.png',
                height: 96,
                width: 144,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.business,
                    color: Colors.grey[700],
                    size: 24,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(height: 1.0, color: Colors.grey[300]),
        ),
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
              labelType: NavigationRailLabelType.none,
              extended: isExtended,
              minWidth: 72,
              minExtendedWidth: 200,
              destinations: railDestinations,
              backgroundColor: Colors.white,
              selectedIconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.primary,
              ),
              selectedLabelTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              unselectedIconTheme: IconThemeData(color: Colors.grey[700]),
              unselectedLabelTextStyle: TextStyle(color: Colors.grey[700]),
              indicatorColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
            ),
          ),
          VerticalDivider(thickness: 1, width: 1, color: Colors.grey[300]),
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
