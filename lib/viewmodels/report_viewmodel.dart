import 'package:corruption2/viewmodels/admin_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/report_model.dart';
import '../services/location_service.dart';
import '../services/file_picker_service.dart';
import 'dart:io';
import 'dart:convert';

class ReportViewModel with ChangeNotifier {
  List<Report> _reports = [];
  File? _imageFile;
  File? _videoFile;
  String _location = '';
  String _error = '';
  String _corruptionType = "Ma'muriy korrupsiya";
  bool _includeMedia = false;
  bool _isAnonymous = false;
  String? _trackingCode;
  bool _isLoading = false;

  List<Report> get reports => _reports;
  File? get imageFile => _imageFile;
  File? get videoFile => _videoFile;
  String get location => _location;
  String get error => _error;
  String get corruptionType => _corruptionType;
  bool get includeMedia => _includeMedia;
  bool get isAnonymous => _isAnonymous;
  String? get trackingCode => _trackingCode;
  bool get isLoading => _isLoading;

  ReportViewModel() {
    _loadReports();
  }

  Future<void> _loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = prefs.getString('saved_reports');
    if (reportsJson != null) {
      final List<dynamic> reportsList = jsonDecode(reportsJson);
      _reports = reportsList.map((item) => Report.fromMap(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'saved_reports',
      jsonEncode(_reports.map((r) => r.toMap()).toList()),
    );
    notifyListeners();
  }

  Future<void> syncReportsWithAdmin(AdminViewModel adminViewModel) async {
    await _loadReports();
    await adminViewModel.loadReports();
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    try {
      _error = '';
      _location = "Joylashuv aniqlanmoqda...";
      notifyListeners();
      
      final locationData = await LocationService.getCurrentLocation();
      _location = locationData['fullAddress'];
      notifyListeners();
    } catch (e) {
      _error = "Joylashuvni olishda xatolik: ${e.toString()}";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> pickImage() async {
    try {
      _error = '';
      _isLoading = true;
      notifyListeners();
      
      await FilePickerService.clearTempFiles();
      final file = await FilePickerService.pickImage();
      
      if (file != null) {
        _imageFile = file;
        _videoFile = null;
      }
      notifyListeners();
    } catch (e) {
      _error = "Rasm tanlashda xatolik: ${e.toString()}";
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickVideo() async {
    try {
      _error = '';
      _isLoading = true;
      notifyListeners();
      
      await FilePickerService.clearTempFiles();
      final file = await FilePickerService.pickVideo();
      
      if (file != null) {
        _videoFile = file;
        _imageFile = null;
      }
      notifyListeners();
    } catch (e) {
      _error = "Video tanlashda xatolik: ${e.toString()}";
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCorruptionType(String type) {
    _corruptionType = type;
    notifyListeners();
  }

  void setIncludeMedia(bool value) {
    _includeMedia = value;
    if (!value) {
      _imageFile = null;
      _videoFile = null;
    }
    notifyListeners();
  }

  void setAnonymous(bool value) {
    _isAnonymous = value;
    notifyListeners();
  }

  Future<String?> submitReport(String description) async {
    try {
      if (description.isEmpty) {
        return "Iltimos, tavsifni kiriting";
      }

      if (_location.isEmpty) {
        return "Iltimos, joylashuvni tanlang";
      }

      if (_includeMedia && _imageFile == null && _videoFile == null) {
        return "Iltimos, rasm yoki video tanlang";
      }

      _isLoading = true;
      _error = '';
      notifyListeners();

      final newReport = Report(
        id: const Uuid().v4(),
        type: _corruptionType,
        location: _location,
        description: description,
        status: 'Yangi',
        imagePath: _imageFile?.path,
        videoPath: _videoFile?.path,
        submissionTime: DateTime.now().toIso8601String(),
        isAnonymous: _isAnonymous,
      );

      _reports.add(newReport);
      _trackingCode = "${newReport.id.substring(0, 4).toUpperCase()}${_reports.length}";
      await _saveReports();
      
      // Reset form
      _imageFile = null;
      _videoFile = null;
      _location = '';
      _error = '';
      notifyListeners();

      return null;
    } catch (e) {
      return "Ariza yuborishda xatolik: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Report? getReportById(String id) {
    try {
      return _reports.firstWhere((report) => report.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearForm() {
    _imageFile = null;
    _videoFile = null;
    _location = '';
    _error = '';
    _corruptionType = "Ma'muriy korrupsiya";
    _includeMedia = false;
    _isAnonymous = false;
    notifyListeners();
  }
}