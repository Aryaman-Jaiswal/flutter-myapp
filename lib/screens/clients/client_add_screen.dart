import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/client.dart';
import '../../providers/client_provider.dart';

class ClientAddScreen extends StatefulWidget {
  const ClientAddScreen({super.key});

  @override
  State<ClientAddScreen> createState() => _ClientAddScreenState();
}

class _ClientAddScreenState extends State<ClientAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileNoController =
      TextEditingController(); // NEW CONTROLLER

  String? _selectedCity;
  final List<String> _cities = [
    'Vashi',
    'Chembur',
    'Andheri',
    'Mumbai',
    'Pune',
    'Nagpur',
  ];
  final String _fixedState = 'Maharashtra';

  @override
  void dispose() {
    _nameController.dispose();
    _mobileNoController.dispose(); // Dispose the new controller
    super.dispose();
  }

  void _addClient() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCity == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select a City')));
        return;
      }

      final clientProvider = Provider.of<ClientProvider>(
        context,
        listen: false,
      );
      final newClient = Client(
        name: _nameController.text,
        city: _selectedCity!,
        state: _fixedState,
        mobileNo:
            _mobileNoController.text, // Pass mobile number from controller
      );

      await clientProvider.addClient(newClient);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client Added Successfully!')),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Changed from Scaffold to Padding
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- NEW: Custom Back button and Header ---
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop(); // Uses the local navigator
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          Text(
            'Add New Client',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          // --- END NEW HEADER ---

          // Form wrapped in a Card for the bordered look
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align labels to the left
                  children: [
                    // Client Name
                    const Text(
                      'Client Name*',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Enter client name'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter client name' : null,
                    ),
                    const SizedBox(height: 24.0),

                    // Mobile Number
                    const Text(
                      'Mobile Number*',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _mobileNoController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration('Enter mobile number'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter mobile number' : null,
                    ),
                    const SizedBox(height: 24.0),

                    // City Dropdown
                    const Text(
                      'Select City*',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: _inputDecoration('Select City'),
                      hint: const Text('Select City'),
                      items: _cities.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCity = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a city' : null,
                      isExpanded: true,
                    ),
                    const SizedBox(height: 32.0),

                    // Submit Button
                    Align(
                      alignment:
                          Alignment.centerRight, // Align button to the right
                      child: ElevatedButton(
                        onPressed: _addClient,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text('Add Client'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white, // Changed fill color to white
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Colors.grey[300]!,
          width: 1,
        ), // Light border
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 16.0,
      ),
    );
  }
}
