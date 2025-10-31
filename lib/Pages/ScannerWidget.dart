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
  Color get _primaryColor => Theme.of(context).colorScheme.primary;
  Color get _accentColor => Theme.of(context).colorScheme.secondary;

  final MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = false;
  String? _scannedCode;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return BasePage(
      body: Column(
        children: [
          Expanded(
            child: _isScanning ? _buildScannerCamera() : _buildScannerHomePage(),
          ),
        ],
      ),
    );
  }

  //---------- UI Builders ----------//
  Widget _buildScannerHomePage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 120,
            color: _primaryColor,
          ),
          const SizedBox(height: 32),
          Text(
            'QR Code Scanner',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.fontColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Scan machine codes for payment processing',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isScanning = true;
              });
            },
            icon: Icon(Icons.camera_alt, size: 28, color: _accentColor),
            label: const Text(
              'Start Scanning',
              style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF000000),),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 10
            ),
          ),
          if (_scannedCode != null) ...[
            const SizedBox(height: 32),
            _buildLastScannedBox(_scannedCode!),
          ],
        ],
      ),
    );
  }

  Widget _buildLastScannedBox(String code) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Text(
            'Last Scanned Code:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).colorScheme.fontColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _scannedCode!,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

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
                color: Theme.of(context).colorScheme.fontColor,
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
                setState(() {
                  _isScanning = false;
                });
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
          _isScanning = false;
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