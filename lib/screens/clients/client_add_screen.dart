import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  final TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
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
        city: _cityController.text,
      );

      await clientProvider.addClient(newClient);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client Added Successfully!')),
      );

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Client')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Client Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter client name' : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                    validator: (value) => value!.isEmpty ? 'Enter city' : null,
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
