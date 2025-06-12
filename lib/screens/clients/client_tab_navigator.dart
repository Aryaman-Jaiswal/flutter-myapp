import 'package:flutter/material.dart';
import 'client_add_screen.dart';
import 'client_list_screen.dart';

class ClientTabNavigator extends StatelessWidget {
  const ClientTabNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    // The Navigator widget creates a new routing stack.
    return Navigator(
      initialRoute: '/', // The default route for this tab
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/add': // Route for the "Add New Client" screen
            page = const ClientAddScreen();
            break;
          case '/': // Default route
          default:
            page = const ClientListScreen();
            break;
        }
        return MaterialPageRoute(builder: (context) => page);
      },
    );
  }
}
