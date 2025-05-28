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

  String? _selectedCity;

  final List<String> _cities = [
    'Vashi', 'Chembur', 'Andheri', 'Mumbai', 'Pune', 'Nagpur',
    // Add more cities as needed
  ];
  final String _fixedState = 'Maharashtra';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addClient() async {
    if (_formKey.currentState!.validate()) {
      final clientProvider = Provider.of<ClientProvider>(
        context,
        listen: false,
      );
      final newClient = Client(
        name: _nameController.text,
        city: _selectedCity!,
        state: _fixedState,
      );

      await clientProvider.addClient(newClient);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client Added Successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Client')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Client Name',
                      hintText: 'Enter client name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withAlpha(
                            (0.5 * 255).toInt(),
                          ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2.0,
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withAlpha(
                        (0.3 * 255).toInt(),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter client name' : null,
                  ),
                  const SizedBox(height: 16.0),

                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: InputDecoration(
                      labelText: 'Select City',
                      hintText: 'Choose a city',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withAlpha(
                            (0.5 * 255).toInt(),
                          ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2.0,
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withAlpha(
                        (0.3 * 255).toInt(),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                    ),
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
                    menuMaxHeight: 200,
                  ),
                  const SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: _addClient,
                    child: const Text('Add Client'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
