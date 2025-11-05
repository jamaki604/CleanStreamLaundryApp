import 'package:clean_stream_laundry_app/Components/BasePage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:clean_stream_laundry_app/Logic/QrScanner/QrScannerParser.dart';
import '../Logic/Theme/Theme.dart';

class ScannerWidget extends StatefulWidget {
  const ScannerWidget({super.key});

  @override
  State<ScannerWidget> createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget> {

  final MobileScannerController cameraController = MobileScannerController();
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
              'Point camera at Nayax QR code',
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontPrimary,
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

  //---------- QR Logic ----------//

  void _handleQRCode(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _scannedCode = barcode.rawValue;
        });

        QrScannerParser qrScannerController = QrScannerParser(_scannedCode!);
        _processNayaxCode(qrScannerController.getNayaxDeviceID());
        break;
      }
    }
  }

  void _processNayaxCode(String? code) {
    context.go('/paymentPage?machineId=$code');
  }
}