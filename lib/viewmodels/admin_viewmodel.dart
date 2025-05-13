import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/report_model.dart';

class AdminViewModel with ChangeNotifier {
  List<Report> _reports = [];
  List<Report> _filteredReports = [];
  String _searchQuery = '';

  final List<String> statusOptions = [
    'Yangi',
    "Ko'rib chiqilmoqda",
    'Tekshirilgan',
    'Rad etilgan',
    'Yopilgan'
  ];

  List<Report> get reports => _filteredReports;

  AdminViewModel() {
    loadReports();
  }

  Future<void> loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = prefs.getString('saved_reports');
    
    if (reportsJson != null) {
      final List<dynamic> reportsList = jsonDecode(reportsJson);
      _reports = reportsList.map((item) => Report.fromMap(item)).toList();
      _filterReports();
      notifyListeners();
    }
  }

  Future<void> _saveReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'saved_reports',
      jsonEncode(_reports.map((r) => r.toMap()).toList()),
    );
  }

  void searchReports(String query) {
    _searchQuery = query;
    _filterReports();
    notifyListeners();
  }

  void _filterReports() {
    if (_searchQuery.isEmpty) {
      _filteredReports = List.from(_reports);
    } else {
      _filteredReports = _reports.where((report) {
        return report.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            report.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            report.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  void updateReportStatus(String id, String newStatus) {
    final index = _reports.indexWhere((report) => report.id == id);
    if (index != -1) {
      _reports[index].status = newStatus;
      _saveReports();
      _filterReports();
      notifyListeners();
    }
  }

  void deleteReport(String id) {
    _reports.removeWhere((report) => report.id == id);
    _saveReports();
    _filterReports();
    notifyListeners();
  }
}