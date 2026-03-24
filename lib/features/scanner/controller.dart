import 'package:clean_stream_laundry_app/logic/parsing/qr_parser.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_communication_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerController extends ChangeNotifier {
  final MachineCommunicationService machineCommunicator;

  ScannerController({MachineCommunicationService? machineCommunicator})
      : machineCommunicator = machineCommunicator ??
      GetIt.instance<MachineCommunicationService>();

  final MobileScannerController cameraController = MobileScannerController();

  String? scannedCode;

  void disposeController() {
    cameraController.dispose();
  }

  void handleQRCode(
      BarcodeCapture capture, {
        required void Function(String route) onNavigate,
        required void Function(String title, String message) onError,
      }) async {
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null) {
        scannedCode = barcode.rawValue;
        notifyListeners();
        final parser = QrScannerParser(scannedCode!);
        await processNayaxCode(
          parser.getNayaxDeviceID(),
          onNavigate: onNavigate,
          onError: onError,
        );
        break;
      }
    }
  }

  Future<void> processNayaxCode(
      String? code, {
        required void Function(String route) onNavigate,
        required void Function(String title, String message) onError,
      }) async {
    cameraController.stop();
    final result = await machineCommunicator.checkAvailability(code!);
    if (result == 'pass') {
      onNavigate('/paymentPage?machineId=$code');
    } else {
      onError('Machine Unavailable', result);
      cameraController.start();
    }
  }
}