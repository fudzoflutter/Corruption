import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:corruption2/admin_panel.dart';
import 'package:corruption2/pages/main_navigation_bar.dart';
import 'package:corruption2/viewmodels/admin_viewmodel.dart';
import 'package:corruption2/viewmodels/auth_view_model.dart';
import 'package:corruption2/viewmodels/report_viewmodel.dart';
import 'package:corruption2/viewmodels/status_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReportViewModel()),
        ChangeNotifierProvider(create: (_) => StatusViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Korrupsiyaga Qarshi',
      theme: ThemeData(
        primaryColor: const Color(0xFF2E3B4E),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF2E3B4E),
          secondary: const Color(0xFF4CAF50),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E3B4E),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: MainNavigationPage(),
      routes: {
        '/admin': (context) => const AdminPanel(),
      },
    );
  }
}