import 'package:clean_stream_laundry_app/widgets/base_page.dart';
import 'package:clean_stream_laundry_app/Logic/Services/machine_communication_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:clean_stream_laundry_app/Logic/parsing/qr_parser.dart';
import 'package:clean_stream_laundry_app/widgets/status_dialog_box.dart';

class ScannerWidget extends StatefulWidget {
  const ScannerWidget({super.key});

  @override
  State<ScannerWidget> createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget> {

  final MobileScannerController cameraController = MobileScannerController();
  final machineCommunicator = GetIt.instance<MachineCommunicationService>();
  String? _scannedCode;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
        body: _buildScannerCamera()
    );
  }

  //---------- UI Builders ----------//

  Widget _buildScannerCamera() {
    return Stack(
      children: [
        MobileScanner(
          controller: cameraController,
          onDetect: _handleQRCode,
        ),

        // Top overlay text
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black54,
            padding: const EdgeInsets.all(16),
            child: Text(
              'Point camera at nayax QR code',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Cancel button
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton.extended(
              onPressed: () {
                context.go("/startPage");
              },
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
              backgroundColor: Colors.red,
            ),
          ),
        ),

        // Center frame
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  //---------- QR logic ----------//

  void _handleQRCode(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _scannedCode = barcode.rawValue;
        });

        QrScannerParser qrScannerController = QrScannerParser(_scannedCode!);
        processNayaxCode(qrScannerController.getNayaxDeviceID());
        break;
      }
    }
  }

  Future<void> processNayaxCode(String? code) async {
    cameraController.stop();
    String result = await machineCommunicator.checkAvailability(code!);
    if (result == "pass") {
      context.go('/paymentPage?machineId=$code');
    } else {
      statusDialog(context, title: "Machine Unavailable", message: result, isSuccess: false);
      cameraController.start();
    }
  }
}