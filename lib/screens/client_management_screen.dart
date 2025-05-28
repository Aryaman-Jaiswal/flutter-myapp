import 'package:flutter/material.dart';
import 'clients/client_list_screen.dart';
import 'clients/client_add_screen.dart';


class ClientManagementScreen extends StatelessWidget {
  const ClientManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Account Home / Clients/Groups',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Client/Group Management',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Icon(Icons.list_alt),
                    title: Text('View Client List'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ClientListScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.add_business),
                    title: Text('Add New Client/Group'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ClientAddScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}