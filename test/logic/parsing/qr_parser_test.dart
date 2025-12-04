import 'package:test/test.dart';
import 'package:clean_stream_laundry_app/logic/parsing/qr_parser.dart';

void main(){

  group("qr_scanner.parseURL",(){

    test("Returns the valid NayaxDeviceID",(){
      QrScannerParser qrScannerController = QrScannerParser("https://payment.nayax.com/device?id=12345678");
      expect(qrScannerController.getNayaxDeviceID(),equals("12345678"));
    });

    test("Returns null if the URL is invalid",(){
      QrScannerParser qrScannerController = QrScannerParser("https://payment.nayax.com/");
      expect(qrScannerController.getNayaxDeviceID(),isNull);
    });

    test("Returns null if the URL is malformed", () {
      QrScannerParser qrScannerController = QrScannerParser("ht!tp://malformed-url");
      expect(qrScannerController.getNayaxDeviceID(), isNull);
    });

  });

}