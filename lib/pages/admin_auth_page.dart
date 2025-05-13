import 'package:flutter/material.dart';

class AdminAuthPage extends StatelessWidget {
  final TextEditingController _adminPinController = TextEditingController();

  AdminAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Kirishi')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _adminPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Admin PIN kodi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_adminPinController.text == '1234') { // Demo uchun oddiy PIN
                  Navigator.pushReplacementNamed(context, '/admin');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Noto\'g\'ri PIN kodi')),
                  );
                }
              },
              child: const Text('Kirish'),
            ),
          ],
        ),
      ),
    );
  }
}