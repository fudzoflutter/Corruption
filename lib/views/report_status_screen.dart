import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/report_viewmodel.dart';
import 'dart:io';

class ReportStatusScreen extends StatelessWidget {
  final String reportId;

  const ReportStatusScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ReportViewModel>(context);
    final report = viewModel.getReportById(reportId);

    if (report == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Xato')),
        body: const Center(child: Text('Ariza topilmadi')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ariza Holati'),
        backgroundColor: const Color(0xFF2E3B4E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('ID', report.id),
            _buildInfoCard('Turi', report.type),
            _buildInfoCard('Manzil', report.location),
            _buildInfoCard('Tavsif', report.description),
            _buildStatusCard(report.status),
            _buildInfoCard(
              'Yuborilgan sana',
              DateTime.parse(report.submissionTime).toLocal().toString(),
            ),
            if (report.imagePath != null) _buildImagePreview(report.imagePath!),
            if (report.isAnonymous)
              const Text(
                'Anonim ariza',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    return Card(
      color: _getStatusColor(status),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Text(
              'Holat: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              status,
              style: TextStyle(
                color: _getStatusColor(status),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String imagePath) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12, top: 12),
            child: Text(
              'Yuborilgan rasm:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(
                File(imagePath),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Yangi':
        return Colors.red;
      case "Ko'rib chiqilmoqda":
        return Colors.orange;
      case 'Tekshirilgan':
        return Colors.green;
      case 'Rad etilgan':
        return Colors.redAccent;
      case 'Yopilgan':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }
}