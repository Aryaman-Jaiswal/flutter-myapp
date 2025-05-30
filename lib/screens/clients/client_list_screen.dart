import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/client_provider.dart';
import '../clients/client_add_screen.dart'; // Import for "Add New Client" button
import '../../models/client.dart'; // Import Client model for mock data generation

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  // Filter and Pagination State
  int _currentPage = 1;
  final int _clientsPerPage = 10; // Number of clients per page
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilterTab =
      'All Clients'; // Corresponds to the segmented buttons
  List<String> _filterAttributes = [
    'Attribute 1',
    'Attribute 2',
  ]; // Sample filter attributes
  String? _selectedFilterAttribute;

  // Mock data for filter tabs (no actual filtering implemented yet)
  final List<String> _filterTabs = [
    'All Clients',
    'Leads',
    'Ongoing',
    'Payment Back',
    'Closed',
  ];

  @override
  void initState() {
    super.initState();
    // Load some mock clients for display if none exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final clientProvider = Provider.of<ClientProvider>(
        context,
        listen: false,
      );
      if (clientProvider.clients.isEmpty) {
        _generateMockClients(clientProvider);
      }
      clientProvider.fetchClients();
    });
  }

  // Temporary function to generate some mock clients for initial display
  void _generateMockClients(ClientProvider provider) {
    if (provider.clients.isEmpty) {
      provider.addClient(
        Client(
          name: 'Theresa Webb',
          city: 'Mumbai',
          state: 'Maharashtra',
          mobileNo: '01796-329869', // ADD mobileNo here
          caseRef: 'CC/80564',
          openedAt: '22/10/2022',
          doa: '22/10/2022',
          source: 'Google',
          serviceProvider: 'CC/DGM',
          services: ['S&R', 'Hire', 'VD'],
          value: 230.00,
        ),
      );
      provider.addClient(
        Client(
          name: 'Wade Warren',
          city: 'Pune',
          state: 'Maharashtra',
          mobileNo: '01796-329870', // ADD mobileNo here
          caseRef: 'CC/80565',
          openedAt: '22/10/2022',
          doa: '22/10/2022',
          source: 'LinkedIn',
          serviceProvider: 'CC/DGM',
          services: ['S&R', 'Hire'],
          value: 245.50,
        ),
      );
      provider.addClient(
        Client(
          name: 'Kathryn Murphy',
          city: 'Vashi',
          state: 'Maharashtra',
          mobileNo: '01796-329871', // ADD mobileNo here
          caseRef: 'CC/80566',
          openedAt: '22/10/2022',
          doa: '22/10/2022',
          source: 'Facebook',
          serviceProvider: 'CC/DGM',
          services: ['S&R', 'VD'],
          value: 210.00,
        ),
      );
      provider.addClient(
        Client(
          name: 'Ralph Edwards',
          city: 'Andheri',
          state: 'Maharashtra',
          mobileNo: '01796-329872', // ADD mobileNo here
          caseRef: 'CC/80567',
          openedAt: '22/10/2022',
          doa: '22/10/2022',
          source: 'Google',
          serviceProvider: 'CC/DGM',
          services: ['S&R', 'Hire', 'VD'],
          value: 260.00,
        ),
      );
      provider.addClient(
        Client(
          name: 'Esther Howard',
          city: 'Chembur',
          state: 'Maharashtra',
          mobileNo: '01796-329873', // ADD mobileNo here
          caseRef: 'CC/80568',
          openedAt: '22/10/2022',
          doa: '22/10/2022',
          source: 'LinkedIn',
          serviceProvider: 'CC/DGM',
          services: ['S&R'],
          value: 200.00,
        ),
      );
      provider.addClient(
        Client(
          name: 'Annette Black',
          city: 'Mumbai',
          state: 'Maharashtra',
          mobileNo: '01796-329874', // ADD mobileNo here
          caseRef: 'CC/80569',
          openedAt: '22/10/2022',
          doa: '22/10/2022',
          source: 'Google',
          serviceProvider: 'CC/DGM',
          services: ['S&R', 'Hire', 'VD'],
          value: 230.00,
        ),
      );
      provider.addClient(
        Client(
          name: 'Savannah Nguyen',
          city: 'Pune',
          state: 'Maharashtra',
          mobileNo: '01796-329875', // ADD mobileNo here
          caseRef: 'CC/80570',
          openedAt: '22/10/2022',
          doa: '22/10/2022',
          source: 'Google',
          serviceProvider: 'CC/DGM',
          services: ['S&R', 'Hire'],
          value: 245.50,
        ),
      );
      provider.addClient(
        Client(
          name: 'Cameron Williamson',
          city: 'Vashi',
          state: 'Maharashtra',
          mobileNo: '01796-329876', // ADD mobileNo here
          caseRef: 'CC/80571',
          openedAt: '22/10/2022',
          doa: '22/10/2022',
          source: 'Facebook',
          serviceProvider: 'CC/DGM',
          services: ['S&R', 'VD'],
          value: 210.00,
        ),
      );
      provider.addClient(
        Client(
          name: 'Brooklyn Simmons',
          city: 'Andheri',
          state: 'Maharashtra',
          mobileNo: '01796-329877', // ADD mobileNo here
          caseRef: 'CC/80572',
          openedAt: '22/10/2022',
          doa: '22/10/2022',
          source: 'Google',
          serviceProvider: 'CC/DGM',
          services: ['S&R', 'Hire', 'VD'],
          value: 260.00,
        ),
      );
      provider.addClient(
        Client(
          name: 'Dianne Russell',
          city: 'Chembur',
          state: 'Maharashtra',
          mobileNo: '01796-329878', // ADD mobileNo here
          caseRef: 'CC/80573',
          openedAt: '22/10/2022',
          doa: '22/10/2022',
          source: 'LinkedIn',
          serviceProvider: 'CC/DGM',
          services: ['S&R'],
          value: 200.00,
        ),
      );
      provider.addClient(
        Client(
          name: 'Bessie Cooper',
          city: 'Mumbai',
          state: 'Maharashtra',
          mobileNo: '01796-329879', // ADD mobileNo here
          caseRef: 'CC/80574',
          openedAt: '22/10/2022',
          doa: '22/10/2022',
          source: 'Google',
          serviceProvider: 'CC/DGM',
          services: ['S&R', 'Hire', 'VD'],
          value: 230.00,
        ),
      );
      provider.addClient(
        Client(
          name: 'Guy Hawkins',
          city: 'Pune',
          state: 'Maharashtra',
          mobileNo: '01796-329880', // ADD mobileNo here
          caseRef: 'CC/80575',
          openedAt: '22/10/2022',
          doa: '22/10/2022',
          source: 'LinkedIn',
          serviceProvider: 'CC/DGM',
          services: ['S&R', 'Hire'],
          value: 245.50,
        ),
      );
      provider.addClient(
        Client(
          name: 'Jacob Jones',
          city: 'Vashi',
          state: 'Maharashtra',
          mobileNo: '01796-329881', // ADD mobileNo here
          caseRef: 'CC/80576',
          openedAt: '22/10/2022',
          doa: '22/10/2022',
          source: 'Facebook',
          serviceProvider: 'CC/DGM',
          services: ['S&R', 'VD'],
          value: 210.00,
        ),
      );
      provider.addClient(
        Client(
          name: 'Arlene McCoy',
          city: 'Andheri',
          state: 'Maharashtra',
          mobileNo: '01796-329882', // ADD mobileNo here
          caseRef: 'CC/80577',
          openedAt: '22/10/2022',
          doa: '22/10/2022',
          source: 'Google',
          serviceProvider: 'CC/DGM',
          services: ['S&R', 'Hire', 'VD'],
          value: 260.00,
        ),
      );
      provider.addClient(
        Client(
          name: 'Devon Lane',
          city: 'Chembur',
          state: 'Maharashtra',
          mobileNo: '01796-329883', // ADD mobileNo here
          caseRef: 'CC/80578',
          openedAt: '22/10/2022',
          doa: '22/10/2022',
          source: 'LinkedIn',
          serviceProvider: 'CC/DGM',
          services: ['S&R'],
          value: 200.00,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Filter Clients'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Filter Attribute',
                  border: OutlineInputBorder(),
                ),
                value: _selectedFilterAttribute,
                items: _filterAttributes.map((String attr) {
                  return DropdownMenuItem<String>(
                    value: attr,
                    child: Text(attr),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFilterAttribute = newValue;
                  });
                },
              ),
              // Add more filter options here (e.g., date pickers, text inputs)
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _selectedFilterAttribute = null; // Clear filter on cancel
                });
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement actual filtering logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Applying filter: $_selectedFilterAttribute'),
                  ),
                );
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Apply Filter'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Move filtering and pagination logic here so totalPages is available for pagination controls
    final clientProvider = Provider.of<ClientProvider>(context);
    List<Client> filteredClients = clientProvider.clients;

    // Apply search filter (basic, case-insensitive substring match)
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filteredClients = filteredClients.where((client) {
        return client.name.toLowerCase().contains(query) ||
            client.caseRef.toLowerCase().contains(query) ||
            client.city.toLowerCase().contains(query) ||
            client.state.toLowerCase().contains(query);
      }).toList();
    }

    // Apply filter attribute (mock logic)
    if (_selectedFilterAttribute != null) {
      filteredClients = filteredClients.where((client) {
        // Replace with actual filtering logic based on attributes
        // For now, a placeholder that just filters if 'Vashi' is selected city
        if (_selectedFilterAttribute == 'Attribute 1' &&
            client.city == 'Vashi') {
          return true;
        }
        if (_selectedFilterAttribute == 'Attribute 2' &&
            client.source == 'Google') {
          return true;
        }
        return false; // Default: hide if filter is active but doesn't match mock
      }).toList();
    }

    final int totalClients = filteredClients.length;
    // Ensure currentPage doesn't exceed totalPages after filtering
    final int totalPages = (totalClients / _clientsPerPage).ceil();
    if (_currentPage > totalPages && totalPages > 0) {
      _currentPage = totalPages;
    } else if (totalPages == 0) {
      _currentPage = 1; // Or handle as no pages
    }

    final int startIndex = (_currentPage - 1) * _clientsPerPage;
    int endIndex = startIndex + _clientsPerPage;
    if (endIndex > totalClients) {
      endIndex = totalClients;
    }
    final List<Client> clientsOnPage = filteredClients.isNotEmpty
        ? filteredClients.sublist(startIndex, endIndex)
        : [];

    return Container(
      // Use Container to apply light grey background
      color: Colors.grey[50], // Very light grey background for the content area
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb - As per the image, this is part of the global header,
          // but we'll keep it here for now if needed for context within this view.
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 16.0),
          //   child: Text(
          //     'Account Home / Clients/Groups',
          //     style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          //   ),
          // ),

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
                          ?.copyWith(fontWeight: FontWeight.bold),
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
                      icon: const Icon(Icons.download),
                      label: const Text('Export'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700], // Text/icon color
                        side: BorderSide(
                          color: Colors.grey[300]!,
                        ), // Border color
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ClientAddScreen(),
                          ),
                        );
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

          // Section 2: Filter Tabs (Segmented Buttons)
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              children: _filterTabs.map((tab) {
                bool isSelected = _selectedFilterTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      tab,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Colors.grey[200],
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilterTab = tab;
                        // Implement actual filtering based on tab selection here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Selected filter tab: $tab')),
                        );
                        _currentPage = 1; // Reset page on filter change
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Section 3: Search, Date Picker, Filters
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for clients, vehicles and more',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide.none, // No border for a cleaner look
                      ),
                      filled: true,
                      fillColor: Colors
                          .white, // ADDED: White background for search bar
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ), // Added padding for better look
                    ),
                    onChanged: (query) {
                      // Implement live search filtering here
                      setState(() {
                        _currentPage = 1; // Reset page on search change
                      });
                      print('Search query: $query');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Date Range Picker (Placeholder)
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Date picker not implemented.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today, color: Colors.grey),
                  label: const Text(
                    'Jan 6, 2022 - Jan 13, 2022',
                    style: TextStyle(color: Colors.grey),
                  ),
                  style: OutlinedButton.styleFrom(
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
                // Filter Button
                OutlinedButton.icon(
                  onPressed: () => _showFilterDialog(context),
                  icon: const Icon(Icons.filter_list, color: Colors.grey),
                  label: const Text(
                    'Filters',
                    style: TextStyle(color: Colors.grey),
                  ),
                  style: OutlinedButton.styleFrom(
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
              ],
            ),
          ),
          // Section 4: Client List (Table-like Display)
          Expanded(
            // Takes remaining space for the list
            child: Card(
              // Wrap list in a Card for the white background and shadow
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: filteredClients.isEmpty
                  ? const Center(child: Text('No clients found.'))
                  : Column(
                      children: [
                        // Table Header Row
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
                              ), // Checkbox for select all
                              const SizedBox(width: 8),
                              _tableHeaderCell('Client', flex: 3),
                              _tableHeaderCell('Case Ref', flex: 2),
                              _tableHeaderCell('Opened at', flex: 2),
                              _tableHeaderCell('DOA', flex: 2),
                              _tableHeaderCell('Source', flex: 2),
                              _tableHeaderCell('Ser. Provider', flex: 2),
                              _tableHeaderCell('Services', flex: 3),
                              _tableHeaderCell('Value', flex: 2),
                            ],
                          ),
                        ),
                        const Divider(height: 1), // Separator below header
                        // Client List Rows
                        Expanded(
                          child: ListView.separated(
                            itemCount: clientsOnPage.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final client = clientsOnPage[index];
                              return _buildClientRow(client);
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // Section 5: Pagination Controls
          // Only show pagination if there are clients
          if (totalPages > 0) // ADDED: Only show pagination if totalPages > 0
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous Button
                  OutlinedButton.icon(
                    onPressed: _currentPage > 1
                        ? () {
                            setState(() {
                              _currentPage--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  // Page Numbers
                  Row(
                    children: [
                      // Revised pagination logic to dynamically show relevant pages
                      if (_currentPage > 3 && totalPages > 5) ...[
                        // If current page is far from start
                        _buildPageNumber(1),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text('...'),
                        ),
                      ],
                      ...List.generate(totalPages, (index) {
                            final pageNumber = index + 1;
                            // Only show pages around the current one, plus first/last if far
                            if (pageNumber == _currentPage ||
                                (pageNumber >= _currentPage - 2 &&
                                    pageNumber <= _currentPage + 2) ||
                                pageNumber == 1 ||
                                pageNumber == totalPages) {
                              // This logic can be refined for more complex pagination
                              return _buildPageNumber(pageNumber);
                            } else if ((pageNumber == _currentPage - 3 ||
                                    pageNumber == _currentPage + 3) &&
                                totalPages > 5) {
                              // Add ellipsis only if there's a gap AND not at edges
                              return const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text('...'),
                              );
                            }
                            return const SizedBox.shrink(); // Hide other page numbers
                          })
                          .where(
                            (widget) =>
                                widget is! SizedBox ||
                                (widget as SizedBox).child != null,
                          )
                          .toList(),
                    ],
                  ),
                  // Next Button
                  OutlinedButton.icon(
                    onPressed: _currentPage < totalPages
                        ? () {
                            setState(() {
                              _currentPage++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Helper widget for table header cells
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

  // Helper widget to build a single client row
  Widget _buildClientRow(Client client) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Checkbox(value: false, onChanged: (val) {}),
          ), // Checkbox for individual row selection
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                  child: Text(
                    client.name[0], // First letter of name
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      client
                          .mobileNo, // Display the actual mobileNo from the client object
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _tableCell(client.caseRef, flex: 2),
          _tableCell(client.openedAt, flex: 2),
          _tableCell(client.doa, flex: 2),
          _tableCell(client.source, flex: 2),
          _tableCell(client.serviceProvider, flex: 2),
          Expanded(
            flex: 3,
            child: Row(
              children: client.services
                  .map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Chip(
                        label: Text(
                          service,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap, // Compact chip
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          _tableCell('\$${client.value.toStringAsFixed(2)}', flex: 2),
        ],
      ),
    );
  }

  // Helper widget for regular table cells
  Widget _tableCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Helper widget to build page number circles
  Widget _buildPageNumber(int pageNumber) {
    bool isSelected = pageNumber == _currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _currentPage = pageNumber;
          });
        },
        child: CircleAvatar(
          radius: 18,
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).toInt())
              : Colors.transparent,
          child: Text(
            '$pageNumber',
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
