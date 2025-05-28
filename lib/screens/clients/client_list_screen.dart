import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/client_provider.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientProvider>(context, listen: false).fetchClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client List')),
      body: Consumer<ClientProvider>(
        builder: (context, clientProvider, child) {
          if (clientProvider.clients.isEmpty) {
            return const Center(child: Text('No clients added yet.'));
          }
          return ListView.builder(
            itemCount: clientProvider.clients.length,
            itemBuilder: (context, index) {
              final client = clientProvider.clients[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(client.name),
                  subtitle: Text('${client.city}, ${client.state}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      bool? confirmDelete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: Text(
                              'Are you sure you want to delete ${client.name}?',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirmDelete == true) {
                        await clientProvider.deleteClient(client.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Client deleted successfully!'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
