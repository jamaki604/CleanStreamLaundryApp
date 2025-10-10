import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = false;
  String? _scannedCode;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleQRCode(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _scannedCode = barcode.rawValue;
          _isScanning = false;
        });

        // Process Nayax QR code here
        _processNayaxCode(barcode.rawValue!);
        break;
      }
    }
  }

  void _processNayaxCode(String code) {
    showDialog(
      context: context,
      builder: (contect) => AlertDialog(
        title: const Text('QR Code Scanned'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nayax Code:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(code),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _scannedCode = null;
              });
            },
            child: const Text('OK'),
          ),
        ],
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: AppBar(
              title: Image.asset(
                  'lib/assets/Slogan.png',
                  height: 50,
                  fit: BoxFit.contain
              ),
              centerTitle: true,
              elevation: 0,
            ),
          ),
          Expanded(
            child: _isScanning ? _buildScanner() : _buildHomePage(),
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 120,
            color: Color(0xFF2073A9),
          ),
          const SizedBox(height: 32),
          const Text(
            'QR Code Scanner',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
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
            icon: const Icon(Icons.camera_alt, size: 28, color: Color(0xFFf3c404)),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  const Text(
                    'Last Scanned Code:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          controller: cameraController,
          onDetect: _handleQRCode,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black54,
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Point camera at Nayax QR code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
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
}