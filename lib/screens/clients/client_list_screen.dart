import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/client_provider.dart';
// import '../clients/client_add_screen.dart'; // Import for "Add New Client" button
import '../../models/client.dart'; // Import Client model

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
      final clientProvider = Provider.of<ClientProvider>(
        context,
        listen: false,
      );
      clientProvider.fetchClients(); // Just fetch existing clients
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    List<Client> clientsToDisplay = clientProvider.clients;

    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: "Clients" Title, Description, Export, Add New
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clients',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                    ),
                    Text(
                      'View all of your Client information.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exporting clients...')),
                        );
                      },
                      icon: const Icon(Icons.download, color: Colors.black),
                      label: const Text(
                        'Export',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go('/clients/add');
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Add New',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Section 4: Client List (Simplified Table-like Display)
          Expanded(
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: clientsToDisplay.isEmpty
                  ? const Center(
                      child: Text(
                        'No clients found. Add a new client to get started!',
                      ),
                    )
                  : Column(
                      children: [
                        // Table Header Row - MODIFIED
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                child: Checkbox(
                                  value: false,
                                  onChanged: (val) {},
                                ),
                              ),
                              const SizedBox(width: 8),
                              _tableHeaderCell('Client Name', flex: 3),
                              // REMOVED: _tableHeaderCell('Mobile No', flex: 2), // REMOVE THIS LINE
                              _tableHeaderCell('City', flex: 2),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        // Client List Rows - SIMPLIFIED
                        Expanded(
                          child: ListView.separated(
                            itemCount: clientsToDisplay.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1, color: Colors.grey),
                            itemBuilder: (context, index) {
                              final client = clientsToDisplay[index];
                              return _buildClientRow(client);
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for table header cells (unchanged, but fewer calls)
  Widget _tableHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
          fontSize: 12,
        ),
      ),
    );
  }

  // Helper widget to build a single client row - MODIFIED
  Widget _buildClientRow(Client client) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Checkbox(value: false, onChanged: (val) {}),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    client.name[0].toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      // Keep Mobile No here, as it's displayed below the name
                      client.mobileNo,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // REMOVED: _tableCell(client.mobileNo, flex: 2), // REMOVE THIS LINE
          _tableCell(client.city, flex: 2),
        ],
      ),
    );
  }

  // Helper widget for regular table cells (unchanged, but fewer calls)
  Widget _tableCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
