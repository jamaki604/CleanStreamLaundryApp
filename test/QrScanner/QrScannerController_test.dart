import 'package:test/test.dart';
import 'package:clean_stream_laundry_app/QrScanner/QrScannerParser.dart';

void main(){

  group("QrScanner.parseURL",(){

    test("Returns the valid NayaxDeviceID",(){
      QrScannerParser qrScannerController = QrScannerParser("https://cleanstreamlaundry.com/pay/?nayaxDeviceID=12345");
      expect(qrScannerController.getNayaxDeviceID(),equals("12345"));
    });

    test("Returns null if the URL is invalid",(){
      QrScannerParser qrScannerController = QrScannerParser("https://cleanstreamlaundry.com/pay/");
      expect(qrScannerController.getNayaxDeviceID(),isNull);
    });

  });

}