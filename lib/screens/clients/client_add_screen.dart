import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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

      if (mounted) {
        context.go('/clients');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/clients'),
        ),
        title: const Text(
          'Add New Client',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 24),

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
              const SizedBox(height: 24),

              const Text(
                'Select City*',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: _inputDecoration('Select city'),
                hint: const Text('Select city'),
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
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity, // Make button take full width
                height: 50, // Set fixed height
                child: ElevatedButton(
                  onPressed: _addClient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF4C527D,
                    ), // Dark purple/blue color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 0, // Flat button
                  ),
                  child: const Text(
                    'Add Client',
                    style: TextStyle(
                      color: Colors.white, // Explicitly set text color to white
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey[100], // Light grey fill
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none, // No border for a cleaner look
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 16.0,
      ),
    );
  }
}
