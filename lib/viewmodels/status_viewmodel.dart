import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/report_model.dart';

class StatusViewModel with ChangeNotifier {
  List<Report> _reports = [];
  bool _isLoading = false;

  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;

  Future<void> loadReports() async {
    try {
      _isLoading = true;
      // Bu yerda notifyListeners() chaqirmaymiz
      
      final prefs = await SharedPreferences.getInstance();
      final reportsJson = prefs.getString('saved_reports');
      
      if (reportsJson != null) {
        final List<dynamic> reportsList = jsonDecode(reportsJson);
        _reports = reportsList.map((item) => Report.fromMap(item)).toList();
      }
    } catch (e) {
      debugPrint("Xatolik yuz berdi: ${e.toString()}");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners(); // Faqat yakunida bir marta chaqiramiz
    }
  }

  Report? getReportByTrackingCode(String code) {
    try {
      final idPart = code.substring(0, 4).toLowerCase();
      final numberPart = int.tryParse(code.substring(4)) ?? 0;
      
      return _reports.firstWhere((report) => 
        report.id.startsWith(idPart) && 
        _reports.indexOf(report) == numberPart - 1
      );
    } catch (e) {
      return null;
    }
  }
}