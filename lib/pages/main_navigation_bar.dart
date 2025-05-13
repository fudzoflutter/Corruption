import 'package:corruption2/widgets/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'report_page.dart';
import 'settings_page.dart';
import 'status_check_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  _MainNavigationPageState createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    ReportPage(),
    const StatusPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Korrupsiyaga Qarshi'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E3B4E),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}