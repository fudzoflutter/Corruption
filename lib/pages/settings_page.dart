import 'package:corruption2/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'admin_auth_page.dart';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _pinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isFirstTimePinSetup = true;
  File? _newProfileImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.initialize();
      setState(() {
        _isFirstTimePinSetup = !authViewModel.isPinSet;
      });
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF2E3B4E),
        title: const Text('Sozlamalar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profil rasmi
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _newProfileImage != null
                      ? FileImage(_newProfileImage!)
                      : (authViewModel.profileImage != null
                          ? FileImage(authViewModel.profileImage!)
                          : const AssetImage('assets/default_profile.jpg')
                              as ImageProvider),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () => _pickProfileImage(authViewModel),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Profil'),
            subtitle: Text(authViewModel.userEmail ?? 'Anonim foydalanuvchi'),
          ),
          const Divider(),
          
          // Xavfsizlik
          ListTile(
            leading: const Icon(Icons.lock, color: Color(0xFF4CAF50)),
            title: const Text('PIN kodni o\'zgartirish'),
            onTap: () => _showSecurityDialog(context),
          ),
          
          // Admin paneli
          if (!authViewModel.isAdmin)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF4CAF50)),
              title: const Text('Admin bo\'lib kirish'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  AdminAuthPage()),
              ),
            ),
          if (authViewModel.isAdmin)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF4CAF50)),
              title: const Text('Admin Panel'),
              onTap: () => Navigator.pushNamed(context, '/admin'),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Chiqish'),
            onTap: () {
              authViewModel.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickProfileImage(AuthViewModel authViewModel) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _newProfileImage = File(pickedFile.path);
        });
        await authViewModel.setProfileImage(_newProfileImage!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil rasmi yangilandi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rasm yuklashda xatolik: $e')),
      );
    }
  }

  void _showSecurityDialog(BuildContext context) {
    _pinController.clear();
    _newPinController.clear();
    _confirmPinController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_isFirstTimePinSetup ? 'PIN kodni o\'rnatish' : 'PIN kodni o\'zgartirish'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isFirstTimePinSetup) ...[
                  TextField(
                    controller: _pinController,
                    decoration: const InputDecoration(
                      labelText: 'Joriy PIN',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _newPinController,
                  decoration: const InputDecoration(
                    labelText: 'Yangi PIN',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPinController,
                  decoration: const InputDecoration(
                    labelText: 'Yangi PIN tasdiqlash',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _savePinCode(context),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish'),
            ),
            TextButton(
              onPressed: () => _savePinCode(context),
              child: const Text('Saqlash'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePinCode(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Validate current PIN if not first time setup
    if (!_isFirstTimePinSetup) {
      if (_pinController.text.length != 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joriy PIN 4 raqamdan iborat bo\'lishi kerak')),
        );
        return;
      }
      
      if (!await authViewModel.verifyPin(_pinController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joriy PIN noto\'g\'ri')),
        );
        return;
      }
    }

    // Validate new PIN
    if (_newPinController.text.length != 4 || 
        _confirmPinController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN kod 4 raqamdan iborat bo\'lishi kerak')),
      );
      return;
    }

    if (_newPinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yangi PIN kodlar mos kelmadi')),
      );
      return;
    }

    // Save new PIN
    final success = await authViewModel.setPin(_newPinController.text);
    if (success) {
      setState(() {
        _isFirstTimePinSetup = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN kod muvaffaqiyatli saqlandi')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN kodni saqlashda xatolik yuz berdi')),
      );
    }
  }
}