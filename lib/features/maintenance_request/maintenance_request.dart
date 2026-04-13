import 'controller.dart';
import 'widgets/maintenance_form.dart';
import 'widgets/header.dart';
import 'package:clean_stream_laundry_app/core/theme/theme.dart';
import 'package:clean_stream_laundry_app/features/widgets/status_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class MaintenancePage extends StatefulWidget {
  final MaintenanceController? controller;
  const MaintenancePage({super.key, this.controller});

  @override
  State<MaintenancePage> createState() => MaintenancePageState();
}

class MaintenancePageState extends State<MaintenancePage> {
  late final MaintenanceController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? MaintenanceController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.descriptionController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.disposeController();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onSubmitPressed() async {
    _controller.markAttemptedSubmit();
    if (!_controller.isFormValid) return;
    await _handleMaintenance();
  }

  Future<void> _handleMaintenance() async {
    try {
      final success = await _controller.submitMaintenance();
      if (!mounted) return;

      if (!success) return;

      _showMaintenanceDialog();
    } catch (e) {
      if (!mounted) return;
    }
  }

  void _showMaintenanceDialog() {
    statusDialog(
      context,
      title: 'Success',
      message: 'Your maintenance request has been submitted',
      isSuccess: true,
    ).then((_) {
      if (mounted) context.go('/settings');
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        title: const Text('Request Maintenance',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: colorScheme.primaryGradient,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(),
            const SizedBox(height: 28),
            MaintenanceForm(controller: _controller),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _controller.isLoading ? null : _onSubmitPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _controller.isFormValid
                      ? colorScheme.primary
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: _controller.isFormValid ? 2 : 0,
                ),
                child: _controller.isLoading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Text(
                  'Submit Maintenance Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}