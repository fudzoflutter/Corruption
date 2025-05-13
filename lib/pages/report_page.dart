import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/report_viewmodel.dart';
import '../viewmodels/admin_viewmodel.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 24),
              _buildCorruptionTypeField(),
              const SizedBox(height: 20),
              _buildLocationField(),
              const SizedBox(height: 20),
              _buildDescriptionField(),
              const SizedBox(height: 20),
              _buildMediaUploadToggle(),
              const SizedBox(height: 20),
              _buildAnonymityToggle(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorruptionTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Korrupsiya turi*',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E3B4E),
          ),
        ),
        const SizedBox(height: 8),
        Consumer<ReportViewModel>(
          builder: (context, vm, child) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonFormField<String>(
                value: vm.corruptionType,
                items: const [
                  DropdownMenuItem(
                    value: "Ma'muriy korrupsiya",
                    child: Text("Ma'muriy korrupsiya"),
                  ),
                  DropdownMenuItem(
                    value: 'Siyosiy korrupsiya',
                    child: Text('Siyosiy korrupsiya'),
                  ),
                  DropdownMenuItem(
                    value: "Ta'lim korrupsiya",
                    child: Text("Ta'lim korrupsiya"),
                  ),
                  DropdownMenuItem(
                    value: 'Poraxo\'rlik',
                    child: Text('Poraxo\'rlik'),
                  ),
                  DropdownMenuItem(
                    value: 'Boshqa tur',
                    child: Text('Boshqa tur'),
                  ),
                ],
                onChanged: (val) => vm.setCorruptionType(val!),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tanlang...',
                ),
                validator: (value) =>
                    value == null ? 'Iltimos, turini tanlang' : null,
                isExpanded: true,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Joylashuv*',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E3B4E),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Consumer<ReportViewModel>(
                  builder: (context, vm, child) {
                    return Text(
                      vm.location.isEmpty
                          ? 'Joylashuv aniqlanmadi'
                          : vm.location,
                      style: const TextStyle(fontSize: 16),
                    );
                  },
                ),
              ),
              Consumer<ReportViewModel>(
                builder: (context, vm, child) {
                  return IconButton(
                    icon: const Icon(Icons.location_on, color: Color(0xFF4CAF50)),
                    onPressed: vm.isLoading ? null : () async {
                      await vm.getCurrentLocation();
                      if (vm.error.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(vm.error)),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tavsif*',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E3B4E),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
              hintText: 'Tavsifni kiriting...',
            ),
            validator: (val) =>
                val == null || val.isEmpty ? 'Iltimos, tavsif kiriting' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaUploadToggle() {
    return Consumer<ReportViewModel>(
      builder: (context, vm, child) {
        return Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: vm.includeMedia,
                  onChanged: (val) => vm.setIncludeMedia(val!),
                  activeColor: const Color(0xFF4CAF50),
                ),
                const Text('Rasm/video yuklash'),
              ],
            ),
            if (vm.includeMedia) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: vm.isLoading ? null : () => vm.pickImage(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: vm.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Rasm tanlash'),
              ),
              if (vm.imageFile != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    vm.imageFile!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              if (vm.videoFile != null) ...[
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const Icon(Icons.videocam, size: 40),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          vm.videoFile!.path.split('/').last,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAnonymityToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shaxsiylik*',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E3B4E),
          ),
        ),
        const SizedBox(height: 8),
        Consumer<ReportViewModel>(
          builder: (context, vm, child) {
            return Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: vm.isAnonymous,
                  onChanged: (val) => vm.setAnonymous(val!),
                  activeColor: const Color(0xFF4CAF50),
                ),
                const Text('Anonim'),
                const SizedBox(width: 24),
                Radio<bool>(
                  value: false,
                  groupValue: vm.isAnonymous,
                  onChanged: (val) => vm.setAnonymous(val!),
                  activeColor: const Color(0xFF4CAF50),
                ),
                const Text('Shaxsiy identifikatsiya'),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<ReportViewModel>(
      builder: (context, vm, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: vm.isLoading ? null : () => _submitForm(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: vm.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('YUBORISH', style: TextStyle(fontSize: 16)),
          ),
        );
      },
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    final reportViewModel = Provider.of<ReportViewModel>(context, listen: false);
    final adminViewModel = Provider.of<AdminViewModel>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final error = await reportViewModel.submitReport(_descriptionController.text);

      if (error == null) {
        // Ariza yuborilgandan keyin ma'lumotlarni yangilash
        await reportViewModel.syncReportsWithAdmin(adminViewModel);
        _showSuccessDialog(context, reportViewModel.trackingCode!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String code) {
    final reportViewModel = Provider.of<ReportViewModel>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('XABAR YUBORILDI'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Kuzatuv kodingiz:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bu kodni yozib oling yoki screenshot oling. '
              'Xabar holatini tekshirish uchun ishlatishingiz mumkin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              reportViewModel.clearForm();
              _descriptionController.clear();
            },
            child: const Text('TUSHUNARLI'),
          ),
        ],
      ),
    );
  }
}