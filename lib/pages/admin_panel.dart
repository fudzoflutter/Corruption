import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/admin_viewmodel.dart';
import '../models/report_model.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: const Color(0xFF2E3B4E),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.loadReports(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Qidirish',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (query) => viewModel.searchReports(query),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: viewModel.reports.isEmpty
                ? const Center(child: Text('Arizalar topilmadi'))
                : ListView.builder(
                    itemCount: viewModel.reports.length,
                    itemBuilder: (context, index) {
                      final report = viewModel.reports[index];
                      return _buildReportCard(context, report, viewModel);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
      BuildContext context, Report report, AdminViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(report.type),
        subtitle: Text(report.description),
        trailing: Chip(
          label: Text(report.status),
          backgroundColor: _getStatusColor(report.status),
        ),
        onTap: () => _showReportDetailsDialog(context, report, viewModel),
      ),
    );
  }

  void _showReportDetailsDialog(
      BuildContext context, Report report, AdminViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xabar tafsilotlari'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Turi: ${report.type}'),
              const SizedBox(height: 8),
              Text('Joylashuv: ${report.location}'),
              const SizedBox(height: 8),
              Text('Tavsif: ${report.description}'),
              const SizedBox(height: 8),
              Text('Yuborilgan vaqt: ${report.submissionTime}'),
              if (report.imagePath != null) ...[
                const SizedBox(height: 8),
                Image.file(
                  File(report.imagePath!),
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: report.status,
                items: viewModel.statusOptions
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    viewModel.updateReportStatus(report.id, newValue);
                    Navigator.pop(context);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Holatni o\'zgartirish',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yopish'),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              viewModel.deleteReport(report.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Yangi':
        return Colors.orange[100]!;
      case "Ko'rib chiqilmoqda":
        return Colors.blue[100]!;
      case 'Tekshirilgan':
        return Colors.green[100]!;
      case 'Yopilgan':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}