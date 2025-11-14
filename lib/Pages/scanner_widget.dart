import 'package:clean_stream_laundry_app/Components/base_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:clean_stream_laundry_app/Logic/QrScanner/qr_parser.dart';
import '../Logic/Theme/theme.dart';
import '../Services/Nayax/machine_communicator.dart';

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

  //---------- QR Logic ----------//

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
    MachineCommunicator comm = new MachineCommunicator();
    String result = await comm.pingDevice(code!);
    if (result == "pass") {
      context.go('/paymentPage?machineId=$code');
    } else {
      showError(result);
      cameraController.start();
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Center(
          child: Text(
            "Machine Unavailable",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.fontInverted,
          ),
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}