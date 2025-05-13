import 'package:corruption2/models/report_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/status_viewmodel.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final _trackingCodeController = TextEditingController();
  List<Report> _foundReports = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _trackingCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReports();
    });
  }

  Future<void> _loadReports() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    final statusViewModel = Provider.of<StatusViewModel>(context, listen: false);
    await statusViewModel.loadReports();
    
    if (mounted) {
      setState(() {
        _foundReports = statusViewModel.reports;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text(
                'Holatni tekshirish',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3B4E),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _trackingCodeController,
                decoration: InputDecoration(
                  labelText: 'Kuzatuv kodi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchReports,
                  ),
                ),
                onSubmitted: (_) => _searchReports(),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(child: _buildReportsList()),
            ],
          ),
        ),
      ),
    );
  }

  void _searchReports() {
    final code = _trackingCodeController.text.trim();
    if (code.isEmpty) {
      _loadReports();
      return;
    }

    final statusViewModel = Provider.of<StatusViewModel>(context, listen: false);
    final report = statusViewModel.getReportByTrackingCode(code);

    setState(() {
      _foundReports = report != null ? [report] : [];
    });
  }

  Widget _buildReportsList() {
    if (_foundReports.isEmpty) {
      return const Center(
        child: Text('Hech qanday ariza topilmadi'),
      );
    }

    return ListView.builder(
      itemCount: _foundReports.length,
      itemBuilder: (context, index) {
        final report = _foundReports[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(report.type),
            subtitle: Text(report.description),
            trailing: Chip(
              label: Text(report.status),
              backgroundColor: _getStatusColor(report.status),
            ),
            onTap: () => _showReportDetails(context, report),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Yangi':
        return Colors.blue[100]!;
      case 'Qabul qilindi':
        return Colors.green[100]!;
      case 'Rad etildi':
        return Colors.red[100]!;
      case 'Tekshirilmoqda':
        return Colors.orange[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  void _showReportDetails(BuildContext context, Report report) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(report.type),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tavsif: ${report.description}'),
              const SizedBox(height: 12),
              Text('Joylashuv: ${report.location}'),
              const SizedBox(height: 12),
              Text('Holat: ${report.status}'),
              const SizedBox(height: 12),
              Text('Yuborilgan vaqt: ${_formatDate(report.submissionTime)}'),
              if (report.isAnonymous) const Text('Anonim ariza'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
    } catch (e) {
      return isoDate;
    }
  }
}